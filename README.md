# SafeScan - Spyware Detection App for IPV Victims

## Overview
This app is designed to assist victims of Intimate Partner Violence (IPV), who feel unsafe using their devices. It provides a secure and comprehensive way to detect and manage potential spyware and privacy risks present on their devices.

## Features
- #### Device Scan
  - [x] **App Detection**: Scans all apps on the device and compares them against a predefined CSV file of dual-use and spyware applications.
  - [x] **Ranking System**: Ranks apps from most harmful to least:
      - Red: Downloaded from an external location (off-store)
      - Yellow: Identified as pure spyware
      - Light Blue: Identified as dual-use (e.g., Location 360, and many parental control apps)
  - [x] **Secure Store Launch**: Provides a button for each listed app to launch the secur store it was downloaded from.
  - [x] **In-Device Settings Link**: Links to the in-device settings for each app so the user can check permissions.
  - [ ] **Permission Risks**: if an app has certain permissions activated, the app lists the risks of those permissions and provides recommendations on whether to keep them on or off.

#### Privacy Scan
- [x] **Google Privacy Checkup**: Links to in-device Google privacy checkup settings.
- [x] **Social Media Settings**: Links to the settings pages of popular social media apps installed on the device, with recommendations on which settings to deactivate for enhanced privacy.

#### ADB Feature
- [ ] **Remote Scanning**: Allows a source device (with the app installed) to connect remotely (via Bluetooth, WiFi, or USB) to a target device.
- [ ] **Data Output**: Outputs all scan data from the target device to the source device.
- [ ] **Risk Mitigation**: Enables the victim to get help without having to download anything directly on their device, reducing the risk of alerting their abuser.

## Technology Stack:
- Dart with Flutter: Primary development framework.
- Kotlin: Used for Android-side coding.
- Swift: In development for the iOS version of the app, with URL schemes generated for implementation.

## Getting Started
- Close the repository: ` git clone https://github.com/BriLeighk/SafeScan.git `
- Navigate to the project directory: ` cd SafeScan `
- Install dependencies: ` flutter pub get `
- Run the app: ` flutter run `

