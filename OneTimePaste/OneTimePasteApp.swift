import SwiftUI
import SQLite3
import Foundation

@main
struct OneTimePasteApp: App {
    @StateObject private var backgroundManager = BackgroundManager.shared
    @StateObject private var settings = SettingsManager.shared
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
        .onChange(of: settings.monitoringInterval) { _ in
            // Restart monitoring with new interval if currently active
            backgroundManager.restartMonitoringIfActive()
        }
    }
}
