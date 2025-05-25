import SwiftUI
import AppKit
import SQLite3
import Foundation

struct OTPMessage: Identifiable {
    let id = UUID()
    let code: String
    let sender: String
    let timestamp: Date
    let fullMessage: String
}

enum OTPError: Error, LocalizedError {
    case databaseNotFound
    case databaseError(String)
    
    var errorDescription: String? {
        switch self {
        case .databaseNotFound:
            return "Messages database not found"
        case .databaseError(let message):
            return "Database error: \(message)"
        }
    }
}
