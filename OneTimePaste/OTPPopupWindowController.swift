import SwiftUI
import AppKit

class OTPPopupWindowController {
    private var window: NSWindow?
    
    func showOTPPopup(code: String, sender: String) {
        // Dismiss existing popup if any
        dismissPopup()
        
        let popupView = OTPPopupView(
            otpCode: code,
            sender: sender,
            onDismiss: { [weak self] in
                self?.dismissPopup()
            }
        )
        
        let hostingView = NSHostingView(rootView: popupView)
        
        // Calculate position for bottom-left corner
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        
        let windowWidth: CGFloat = 280
        let windowHeight: CGFloat = 120
        let margin: CGFloat = 40
        
        let windowFrame = NSRect(
            x: screenFrame.minX + margin,
            y: screenFrame.minY + margin,
            width: windowWidth,
            height: windowHeight
        )
        
        window = NSWindow(
            contentRect: windowFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        guard let window = window else { return }
        
        window.contentView = hostingView
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isReleasedWhenClosed = false
        
        window.makeKeyAndOrderFront(nil)
        
        // Auto-dismiss after delay as backup
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [weak self] in
            self?.dismissPopup()
        }
    }
    
    func dismissPopup() {
        window?.close()
        window = nil
    }
}
