import SwiftUI
import AppKit
import SQLite3
import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    func showOTPAlert(code: String, playSound: Bool = true) {
        let content = UNMutableNotificationContent()
        content.title = "🔑 OTP Copied to Clipboard"
        content.body = "One-Time Passcode: \(code)"
        
        if playSound {
            content.sound = .default
        } else {
            content.sound = nil
        }

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
