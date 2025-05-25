import AppKit
import Foundation
import SQLite3
import SwiftUI
import UserNotifications

class BackgroundAppManager: NSObject, ObservableObject {
    static let shared = BackgroundAppManager()

    private var statusItem: NSStatusItem?
    private var monitoringTimer: Timer?
    @Published var isMonitoring = false
    private var lastOTPCount = 0
    private var contextMenu: NSMenu?
    private var mainWindow: NSWindow?

    override init() {
        super.init()
        startMonitoring()
        setupMenuBar()
        setupNotifications()
        NSApp.setActivationPolicy(.accessory)
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "key.fill", accessibilityDescription: "OTP Extractor")
        }

        updateMenuBarIcon()
        createContextMenu()
        
        if let menu = contextMenu {
            statusItem?.menu = menu
        }
    }

    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
            granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    private func createContextMenu() {
        contextMenu = NSMenu()
        updateContextMenuItems()
    }
    
    private func updateContextMenuItems() {
        guard let menu = contextMenu else { return }
        
        menu.removeAllItems()

        let monitorTitle = isMonitoring ? "Stop Monitoring" : "Start Monitoring"
        let monitorItem = NSMenuItem(
            title: monitorTitle, action: #selector(toggleMonitoring), keyEquivalent: "")
        monitorItem.target = self
        menu.addItem(monitorItem)

        let status = isMonitoring ? "🟢 Monitoring Active" : "🔴 Monitoring Stopped"
        let statusMenuItem = NSMenuItem(title: status, action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit OTP Extractor", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }
    
    @objc private func toggleMonitoring() {
        if isMonitoring {
            stopMonitoring()
        } else {
            startMonitoring()
        }
        updateContextMenuItems()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    func startMonitoring() {
        isMonitoring = true
        updateMenuBarIcon()

        Task {
            do {
                let foundOTPs = try await extractOTPs()
                await MainActor.run {
                    self.lastOTPCount = foundOTPs.count
                }
            } catch {
                print("Initial scan error: \(error)")
            }
        }

        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            [weak self] timer in
            guard let self = self, self.isMonitoring else {
                timer.invalidate()
                return
            }

            Task {
                await self.checkForNewOTPs()
            }
        }

        print("Background monitoring started")
    }

    func stopMonitoring() {
        isMonitoring = false
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        updateMenuBarIcon()
        print("Background monitoring stopped")
    }

    private func updateMenuBarIcon() {
        if let button = statusItem?.button {
            let symbolName = isMonitoring ? "key.fill" : "key"
            
            if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "OTP Extractor") {
                image.isTemplate = true
                button.image = image
            }
            
            button.contentTintColor = nil
        }
    }

    func hideToMenuBar() {
        mainWindow?.orderOut(nil)
        NSApp.setActivationPolicy(.accessory)
    }

    private func checkForNewOTPs() async {
        do {
            let foundOTPs = try await extractOTPs()
            await MainActor.run {
                if foundOTPs.count > self.lastOTPCount {
                    let newOTPs = Array(foundOTPs.prefix(foundOTPs.count - self.lastOTPCount))

                    for newOTP in newOTPs {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(newOTP.code, forType: .string)

                        NotificationManager.shared.showOTPAlert(code: newOTP.code)
                        NSSound.beep()

                        print("Background: Auto-copied new OTP: \(newOTP.code)")
                    }
                }

                self.lastOTPCount = foundOTPs.count
            }
        } catch {
            print("Background monitoring error: \(error)")
        }
    }
}

extension BackgroundAppManager: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == mainWindow {
            mainWindow = nil
            NSApp.setActivationPolicy(.accessory)
        }
    }
}
