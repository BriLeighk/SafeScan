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
- [ ] **Remote Scanning**: Allows a source device (with the app installed) to connect remotely (via USB) to a target device.
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

## Useful Commands
- ```adb devices```: shell command that enables access to a connected Android device.
- ```adb tcpip 5555```: shell command to enable tcp/ip on the network.
- ```adb shell ip -f inet addr show wlan0```: shell command to get the IP address of the target device.
- ```adb connect <IP_ADDRESS>:5555```: shell command to connect to the target device.
- ```adb shell pm list packages ```: shell command to get list of app packages from the device.
- ```flutter clean```: clear the build cache.
- ```flutter build apk```: build app apk for downloading the app.
- ```flutter intall```: install app on specified device.
- ```dumpsys```: dumps diagnostic information about the status of system services
- ```pm list packages```: lists all packages on the device.

## Attempting to Open Google's Privacy Checkup Directly
```adb shell am start -n com.google.android.gms/com.google.android.gms.accountsettings.mg.ui.main.MainActivity```
Running this adb command causes the following error:
```
Starting: Intent { cmp=com.google.android.gms/.accountsettings.mg.ui.main.MainActivity }
Exception occurred while executing 'start':
java.lang.SecurityException: Permission Denial: starting Intent { flg=0x10000000 cmp=com.google.android.gms/.accountsettings.mg.ui.main.MainActivity } from null (pid=10507, uid=2000) not exported from uid 10212.
```
MainActivity for the in-device Google settings is not exported for external use: [android:exported](https://developer.android.com/privacy-and-security/risks/android-exported#:~:text=The%20android%3Aexported%20attribute%20sets,by%20its%20exact%20class%20name.)

## ADB Connection Solution
Automate ADB Process and enable ADB over the network and connecting to the target device programmatically:
- Add [ADB-OTG](https://github.com/KhunHtetzNaing/ADB-OTG) Library: handles ADB commands.
- Enable ADB over TCP/IP: Implement a method to enable ADB over TCP/IP on both target and source devices.
- Connect to Target Device: Implement a method to connect to the target device using its IP address (can be fetched both programmatically & manually by the user)

### [ADB-OTG Library](https://jitpack.io/#KhunHtetzNaing/ADB-OTG/master)
- Add to root build.gradle
```
dependencyResolutionManagement {
		repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
		repositories {
			mavenCentral()
			maven { url 'https://jitpack.io' }
		}
	}
```
- Add dependency:
```
dependencies {
	        implementation 'com.github.KhunHtetzNaing:ADB-OTG:master'
	}
```
