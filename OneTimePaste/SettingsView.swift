import SwiftUI
import Foundation

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var monitoringInterval: Double {
        didSet {
            UserDefaults.standard.set(monitoringInterval, forKey: "monitoringInterval")
        }
    }
    
    @Published var showNotifications: Bool {
        didSet {
            UserDefaults.standard.set(showNotifications, forKey: "showNotifications")
        }
    }
    
    @Published var playSound: Bool {
        didSet {
            UserDefaults.standard.set(playSound, forKey: "playSound")
        }
    }
    
    @Published var autoCopyToClipboard: Bool {
        didSet {
            UserDefaults.standard.set(autoCopyToClipboard, forKey: "autoCopyToClipboard")
        }
    }
    
    @Published var startOnBoot: Bool {
        didSet {
            UserDefaults.standard.set(startOnBoot, forKey: "startOnBoot")
        }
    }
    
    @Published var minOTPLength: Int {
        didSet {
            UserDefaults.standard.set(minOTPLength, forKey: "minOTPLength")
        }
    }
    
    @Published var maxOTPLength: Int {
        didSet {
            UserDefaults.standard.set(maxOTPLength, forKey: "maxOTPLength")
        }
    }
    
    @Published var showPopup: Bool {
            didSet {
                UserDefaults.standard.set(showPopup, forKey: "showPopup")
            }
        }
    
    private init() {
        self.monitoringInterval = UserDefaults.standard.object(forKey: "monitoringInterval") as? Double ?? 1.0
        self.showNotifications = UserDefaults.standard.object(forKey: "showNotifications") as? Bool ?? true
        self.playSound = UserDefaults.standard.object(forKey: "playSound") as? Bool ?? true
        self.autoCopyToClipboard = UserDefaults.standard.object(forKey: "autoCopyToClipboard") as? Bool ?? true
        self.startOnBoot = UserDefaults.standard.object(forKey: "startOnBoot") as? Bool ?? true
        self.minOTPLength = UserDefaults.standard.object(forKey: "minOTPLength") as? Int ?? 3
        self.maxOTPLength = UserDefaults.standard.object(forKey: "maxOTPLength") as? Int ?? 9
        self.showPopup = UserDefaults.standard.object(forKey: "showPopup") as? Bool ?? true
    }
}

struct SettingsView: View {
    @StateObject private var settings = SettingsManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Image(systemName: "key.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("OneTimePaste Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            
            Divider()
            
            // Monitoring Settings
            VStack(alignment: .leading, spacing: 10) {
                Text("Monitoring")
                    .font(.headline)
                
                HStack {
                    Text("Check interval:")
                    Spacer()
                    Picker("Interval", selection: $settings.monitoringInterval) {
                        Text("0.5 seconds").tag(0.5)
                        Text("1 second").tag(1.0)
                        Text("2 seconds").tag(2.0)
                        Text("5 seconds").tag(5.0)
                    }
                    .pickerStyle(.menu)
                    .frame(width: 150)
                }
                
                HStack {
                    Text("OTP length range:")
                    Spacer()
                    Stepper("\(settings.minOTPLength)", value: $settings.minOTPLength, in: 3...6)
                        .frame(width: 50)
                    Text("to")
                    Stepper("\(settings.maxOTPLength)", value: $settings.maxOTPLength, in: 6...12)
                        .frame(width: 50)
                    Text("digits")
                }
            }
            
            Divider()
            
            // Notification Settings
            VStack(alignment: .leading, spacing: 15) {
                Text("Notifications")
                    .font(.headline)
                
                Toggle("Show notifications when OTP found", isOn: $settings.showNotifications)
                
                Toggle("Play sound when OTP found", isOn: $settings.playSound)
                    .disabled(!settings.showNotifications)
                
                Toggle("Auto-copy OTP to clipboard", isOn: $settings.autoCopyToClipboard)
                
                Toggle("Show popup window when OTP found", isOn: $settings.showPopup)
                
                Toggle("Start OneTimePaste on startup", isOn: $settings.startOnBoot)
            }
            
            Divider()
            
            // Info Section
            VStack(alignment: .leading, spacing: 10) {
                Text("About")
                    .font(.headline)
                
                Text("This app monitors your Messages database for one-time passcodes and automatically copies them to your clipboard. We do not save or share your chat.db, this app runs completely local.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Database path:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("~/Library/Messages/chat.db")
                        .font(.caption)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .frame(width: 450, height: 450)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// Settings Window Controller
class SettingsWindowController: NSWindowController {
    static let shared = SettingsWindowController()
    
    override init(window: NSWindow?) {
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 450),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        super.init(window: settingsWindow)
        
        settingsWindow.title = "Settings"
        settingsWindow.isReleasedWhenClosed = false
        settingsWindow.center()
        settingsWindow.contentView = NSHostingView(rootView: SettingsView())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showSettings() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

#Preview {
    SettingsView()
}
