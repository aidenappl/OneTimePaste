import SwiftUI
import AppKit
import SQLite3
import Foundation

func extractOTPs() async throws -> [OTPMessage] {
    return try await withCheckedThrowingContinuation { continuation in
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let otps = try scanMessagesDatabase()
                continuation.resume(returning: otps)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

func scanMessagesDatabase() throws -> [OTPMessage] {

    let possiblePaths = [
        NSString(string: "~/Library/Messages/chat.db").expandingTildeInPath,
        "/Users/\(NSUserName())/Library/Messages/chat.db"
    ]
    
    var dbPath: String?
    for path in possiblePaths {
        if FileManager.default.fileExists(atPath: path) {
            dbPath = path
            break
        }
    }
    
    guard let validPath = dbPath else {
        throw OTPError.databaseNotFound
    }
    
    var db: OpaquePointer?
    guard sqlite3_open_v2(validPath, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
        throw OTPError.databaseError("Cannot open database")
    }
    defer { sqlite3_close(db) }
    
    let query = """
        SELECT m.text, m.attributedBody, COALESCE(h.id, 'Unknown') as sender, m.date
        FROM message m
        LEFT JOIN handle h ON m.handle_id = h.ROWID
        WHERE (m.text IS NOT NULL AND LENGTH(m.text) > 0)
        OR (m.attributedBody IS NOT NULL AND LENGTH(m.attributedBody) > 0)
        ORDER BY m.date DESC 
        LIMIT 200
    """
    
    var statement: OpaquePointer?
    guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
        throw OTPError.databaseError("Cannot prepare query")
    }
    defer { sqlite3_finalize(statement) }
    
    var messages: [(text: String, sender: String, date: Date)] = []
    
    while sqlite3_step(statement) == SQLITE_ROW {
        var finalText = ""
        
        if sqlite3_column_text(statement, 0) != nil {
            finalText = String(cString: sqlite3_column_text(statement, 0))
        }
        
        // If no text, try attributedBody
        if finalText.isEmpty && sqlite3_column_type(statement, 1) == SQLITE_BLOB {
            let blobLength = sqlite3_column_bytes(statement, 1)
            if blobLength > 0 {
                let blobPointer = sqlite3_column_blob(statement, 1)
                let data = Data(bytes: blobPointer!, count: Int(blobLength))
                
                if let parsedText = parseAttributedBody(data) {
                    finalText = parsedText
                }
            }
        }
        
        if !finalText.isEmpty {
            let sender = String(cString: sqlite3_column_text(statement, 2))
            let dateValue = sqlite3_column_int64(statement, 3)
            let date = Date(timeIntervalSinceReferenceDate: Double(dateValue) / 1_000_000_000)
            
            messages.append((text: finalText, sender: sender, date: date))
        }
    }
    
    var otps: [OTPMessage] = []
    
    for message in messages {
        if let code = findOTPInText(message.text) {
            let otp = OTPMessage(
                code: code,
                sender: message.sender,
                timestamp: message.date,
                fullMessage: message.text
            )
            otps.append(otp)
        }
    }
    
    let uniqueOTPs = Array(Set(otps.map { $0.code }))
        .compactMap { code in otps.first { $0.code == code } }
        .sorted { $0.timestamp > $1.timestamp }
    
    return uniqueOTPs
}

func parseAttributedBody(_ data: Data) -> String? {
    do {
        if let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
            
            if let nsString = plist["NSString"] as? String {
                return nsString
            }
            
            if let nsString = plist["NS.string"] as? String {
                return nsString
            }
            
            func findStrings(in obj: Any) -> [String] {
                var strings: [String] = []
                
                if let string = obj as? String, string.count > 2 {
                    strings.append(string)
                } else if let dict = obj as? [String: Any] {
                    for value in dict.values {
                        strings.append(contentsOf: findStrings(in: value))
                    }
                } else if let array = obj as? [Any] {
                    for item in array {
                        strings.append(contentsOf: findStrings(in: item))
                    }
                }
                
                return strings
            }
            
            let strings = findStrings(in: plist)
            if !strings.isEmpty {
                return strings.joined(separator: " ")
            }
        }
    } catch {
        // TODO
    }
    
    var textChunks: [String] = []
    var currentChunk = ""
    
    for byte in data {
        if byte >= 32 && byte <= 126 {
            let scalar = UnicodeScalar(byte)
            currentChunk += String(Character(scalar))
        } else {
            if currentChunk.count >= 3 {
                textChunks.append(currentChunk)
            }
            currentChunk = ""
        }
    }
    
    if currentChunk.count >= 3 {
        textChunks.append(currentChunk)
    }
    
    if !textChunks.isEmpty {
        let result = textChunks.joined(separator: " ")
        return result.count > 5 ? result : nil
    }
    
    return nil
}

func findOTPInText(_ text: String) -> String? {
    let lowercaseText = text.lowercased()
    
    // Look for 3-9 digit numbers
    let regex = try! NSRegularExpression(pattern: "\\b\\d{3,9}\\b")
    let range = NSRange(location: 0, length: text.utf16.count)
    let matches = regex.matches(in: text, options: [], range: range)
    
    for match in matches {
        let code = (text as NSString).substring(with: match.range)
        
        var score = 0
        
        if code.count >= 4 && code.count <= 6 {
            score += 3
        } else {
            score += 1
        }
        
        // Context keywords
        let otpKeywords = ["code", "verify", "verification", "otp", "login", "security", "confirm", "access"]
        for keyword in otpKeywords {
            if lowercaseText.contains(keyword) {
                score += 2
                break
            }
        }
        
        // Avoid obvious non-OTPs
        let badKeywords = ["price", "total", "phone", "year", "$"]
        for keyword in badKeywords {
            if lowercaseText.contains(keyword) {
                score -= 2
            }
        }
        
        // If it looks like an OTP, return it
        if score > 2 {
            return code
        }
    }
    
    return nil
}
