# OneTimePaste

A lightweight macOS menu bar application that automatically detects one-time passcodes (OTPs) from your Messages and copies them to your clipboard. Eliminates the need to manually search through text messages for verification codes.

## Features

- **Smart OTP Detection**: Automatically scans your Messages database for verification codes
- **Auto-Copy**: Instantly copies detected OTPs to your clipboard
- **Visual Popup**: Bottom-left popup notifications when OTPs are detected
- **System Notifications**: Optional macOS notifications with sound alerts
- **Fully Customizable**: Configure monitoring intervals, OTP length ranges, and notification preferences
- **Launch at Startup**: Optionally start monitoring when you log in
- **Native Design**: Clean, modern macOS interface
- **Privacy-Focused**: All processing happens locally on your device

## Requirements

- macOS 10.15+ (Catalina or later)
- Xcode 14.0+ (for building from source)
- Messages app with iMessage/SMS history

## Installation

### Using Release

Download the release zip file listed in the github repo.

| Build             | Link                                                                |
| ----------------- | ------------------------------------------------------------------- |
| **v.0.1.0-alpha** | https://github.com/aidenappl/OneTimePaste/releases/tag/v0.1.0-alpha |

### Using Source

```bash
# Clone the repository
git clone https://github.com/aidenappl/OneTimePaste.git
cd OneTimePaste

# Open in Xcode
open OneTimePaste.xcodeproj
```

## Configuration & Setup

### Bundle Identifier Setup

**Important**: Before building, change the bundle identifier to your own:

1. Open `OneTimePaste.xcodeproj` in Xcode
2. Select the project in the navigator
3. Go to "Signing & Capabilities"
4. Change **Bundle Identifier** from `com.aidenappleby.OneTimePaste` to your own (e.g., `com.yourname.OneTimePaste`)

### Required Permissions

The app requires specific permissions to function:

#### Messages Database Access

- **Location**: `~/Library/Messages/chat.db`
- **Permission**: The app reads your Messages database directly
- **Privacy**: All processing happens locally; nothing is sent to external servers

#### Required Entitlements:

```xml
<!-- OneTimePaste.entitlements -->
<key>com.apple.security.app-sandbox</key>
<false/>
<key>com.apple.security.automation.apple-events</key>
<true/>
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
```

## Building from Source

### Prerequisites

```bash
# Ensure you have Xcode installed
xcode-select --install
```

### Build Steps

1. **Clone and open**:

   ```bash
   git clone https://github.com/yourusername/OneTimePaste.git
   cd OneTimePaste
   open OneTimePaste.xcodeproj
   ```

2. **Configure signing**:

   - Select your development team
   - Update bundle identifier to your own
   - Ensure entitlements are properly configured

3. **Build and run**:
   - Press `⌘+R` in Xcode, or
   - Build for release: `⌘+Shift+B`

This is a rough install method right now, my fastest way is by creating a new archive, pressing "Distribute" then doing a "Copy" to your desktop. Take the generated folder and inside of it there is the compiled application, copy that to your Applications folder.

## Usage

### First Launch

1. **Grant Permissions**: The app will request necessary permissions for notifications and AppleScript access
2. **Menu Bar Icon**: Look for the key icon in your menu bar
3. **Start Monitoring**: Click the icon and select "Start Monitoring"

### Daily Use

- **Automatic**: Once monitoring is active, OTPs are detected and copied automatically
- **Manual Control**: Use the menu bar to start/stop monitoring as needed
- **Settings**: Right-click the menu bar icon and select "Settings..." to customize behavior

### Settings Configuration

| Setting                | Description                        | Default    |
| ---------------------- | ---------------------------------- | ---------- |
| **Check Interval**     | How often to scan for new messages | 1 second   |
| **OTP Length Range**   | Min/max digits to consider as OTP  | 3-9 digits |
| **Show Notifications** | Display macOS notifications        | Enabled    |
| **Show Popup**         | Display custom popup window        | Enabled    |
| **Play Sound**         | Audio alert when OTP found         | Enabled    |
| **Auto-copy**          | Automatically copy to clipboard    | Enabled    |
| **Launch at Startup**  | Start monitoring at login          | Disabled   |

## Privacy & Security

### Data Privacy

- **Local Processing**: All OTP detection happens on your device
- **No Network Access**: The app doesn't connect to the internet
- **No Data Collection**: Nothing is stored, logged, or transmitted
- **Messages Access**: Read-only access to your local Messages database

### Permissions Breakdown

- **Messages Database Access**: Read OTP codes from text messages
- **Clipboard Access**: Copy detected codes to clipboard
- **Notifications**: Alert you when codes are found
- **Login Items**: Optional startup launch capability
- **AppleScript**: Manage login items for legacy macOS support

## Contributing

Contributions are welcome. To get started:

### Development Setup

```bash
git clone https://github.com/yourusername/OneTimePaste.git
cd OneTimePaste
# Open in Xcode and start development
```

### Contribution Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

### Areas for Contribution

- UI/UX improvements
- Enhanced OTP detection algorithms
- Localization and internationalization
- Bug fixes and performance optimizations
- Documentation improvements

## Troubleshooting

### Common Issues

**App doesn't detect OTPs**

- Ensure Messages app has message history
- Check that monitoring is active (green status in menu)
- Verify OTP length settings match your codes
- Try adjusting monitoring interval

**Permission Errors**

- Grant Full Disk Access in System Preferences > Security & Privacy
- Ensure app is signed with proper entitlements
- Try running with administrator privileges (development only)

**Menu Bar Icon Missing**

- Check if app is running in Activity Monitor
- Try quitting and restarting the app
- Verify menu bar space availability

## License

This project is licensed under the MIT License.

```
MIT License

Copyright (c) 2025 OneTimePaste Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Acknowledgments

- Built using Swift and SwiftUI
- Designed for seamless two-factor authentication experiences
- Community contributions welcome

## Support

- **Issues**: [GitHub Issues](../../issues)
- **Discussions**: [GitHub Discussions](../../discussions)
- **Security**: Report security issues privately

---

**OneTimePaste** - Streamlining macOS two-factor authentication
