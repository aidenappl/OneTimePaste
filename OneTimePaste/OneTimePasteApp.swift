import SwiftUI
import SQLite3
import Foundation

@main
struct OneTimePasteApp: App {
    @StateObject private var backgroundManager = BackgroundAppManager.shared
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
