import SwiftUI
import AppKit

struct OTPPopupView: View {
    let otpCode: String
    let sender: String
    let onDismiss: () -> Void
    @State private var isVisible = false
    @State private var progress: Double = 1.0
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "key.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("OTP Received")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("from \(sender)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .opacity(0.7)
            }
            
            // OTP Code Display
            HStack {
                Text(otpCode)
                    .font(.title)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                
                Button(action: copyToClipboard) {
                    Image(systemName: "doc.on.clipboard")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .help("Copy to clipboard")
            }
            
            // Progress bar
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .accentColor(.blue)
                .tint(.blue)
                .frame(height: 4)
                .animation(.linear(duration: 0.1), value: progress)
        }
        .padding(16)
        .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
            startDismissTimer()
        }
        .frame(width: 280)
    }
    
    private func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(otpCode, forType: .string)
        
        // Brief visual feedback
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
    }
    
    private func startDismissTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            progress = max(0, progress - 0.02) // 5 second countdown, clamped to 0
            
            if progress <= 0 {
                timer.invalidate()
                withAnimation(.easeInOut(duration: 0.3)) {
                    isVisible = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}
