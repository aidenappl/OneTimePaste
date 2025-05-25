//
//  SimpleAlertWindow.swift
//  OneTimePaste
//
//  Created by Aiden Appleby on 5/25/25.
//

import Foundation
import SwiftUI
import AppKit
import SQLite3

class SimpleAlertManager: ObservableObject {
    static let shared = SimpleAlertManager()
    
    func showOTPAlert(code: String) {
        DispatchQueue.main.async {
            // Create a simple alert dialog
            let alert = NSAlert()
            alert.messageText = "OTP Copied to Clipboard"
            alert.informativeText = "One-Time Passcode: \(code)\n\nReady to paste!"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            
            // Run the alert
            alert.runModal()
        }
    }
}
