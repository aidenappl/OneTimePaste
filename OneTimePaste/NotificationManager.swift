import SwiftUI
import AppKit
import SQLite3
import Foundation
import UserNotifications

class SafeNotificationManager: ObservableObject {
    static let shared = SafeNotificationManager()
    
    func showOTPAlert(code: String) {
        let content = UNMutableNotificationContent()
        content.title = "🔑 OTP Copied to Clipboard"
        content.body = "One-Time Passcode: \(code)"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "otp-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
}
