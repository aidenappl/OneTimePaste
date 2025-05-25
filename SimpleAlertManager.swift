//
//  SimpleAlertManager.swift
//  OneTimePaste
//
//  Created by Aiden Appleby on 5/25/25.
//

import SwiftUI
import AppKit
import SQLite3
import Foundation

class SimpleAlertManager: ObservableObject {
    static let shared = SimpleAlertManager()
    
    func showOTPAlert(code: String) {
        DispatchQueue.main.async {
            self.createAndShowAlert(code: code)
        }
    }
    
    private func createAndShowAlert(code: String) {
        // Get screen dimensions
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        
        // Create alert content view
        let alertView = AutoDismissAlert(code: code)
        
        // Create a simple borderless window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 120),
            styleMask: [],  // No style mask = borderless
            backing: .buffered,
            defer: false
        )
        
        window.contentView = NSHostingView(rootView: alertView)
        window.backgroundColor = NSColor.clear
        window.isOpaque = false
        window.level = NSWindow.Level.floating
        window.ignoresMouseEvents = true  // Can't click on it
        
        // Position in bottom-right of screen
        let margin: CGFloat = 20
        let x = screenFrame.maxX - 300 - margin
        let y = screenFrame.minY + margin
        
        window.setFrame(NSRect(x: x, y: y, width: 300, height: 120), display: true)
        window.orderFrontRegardless()
        
        // Auto-close after 3 seconds - no retain cycles
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            window.close()
        }
    }
}

struct AutoDismissAlert: View {
    let code: String
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0.0
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("OTP Copied")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(code)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .tracking(4)
                .foregroundColor(.primary)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            // Animate in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Animate out after 2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    scale = 0.8
                    opacity = 0.0
                }
            }
        }
    }
}
