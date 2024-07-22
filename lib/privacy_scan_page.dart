import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyScanPage extends StatefulWidget {
  const PrivacyScanPage({super.key, required this.scanTarget});

  final bool scanTarget;

  @override
  _PrivacyScanPageState createState() => _PrivacyScanPageState();
}

class _PrivacyScanPageState extends State<PrivacyScanPage> {
  static const MethodChannel appCheckChannel =
      MethodChannel('com.example.spyware/app_check');
  static const MethodChannel appDetailsChannel =
      MethodChannel('com.example.spyware/app_details');

  List<Map<String, String>> installedApps = [];

  @override
  void initState() {
    super.initState();
    _checkInstalledApps();
  }

  Future<bool> _isAppInstalled(String packageName) async {
    try {
      final bool result = await appCheckChannel
          .invokeMethod('isAppInstalled', {'packageName': packageName});
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<void> _checkInstalledApps() async {
    List<String> socialMediaApps = [
      'com.instagram.android',
      'com.snapchat.android',
      'com.facebook.katana',
      'com.twitter.android',
      'com.whatsapp'
    ];
    for (String app in socialMediaApps) {
      bool isInstalled = await _isAppInstalled(app);
      if (isInstalled) {
        Map<String, String>? appDetails = await _getAppDetails(app);
        if (appDetails != null) {
          setState(() {
            installedApps.add(appDetails);
          });
        }
      }
    }
  }

  Future<Map<String, String>?> _getAppDetails(String packageName) async {
    try {
      final Map<dynamic, dynamic> result = await appDetailsChannel
          .invokeMethod('getAppDetails', {'packageName': packageName});
      return Map<String, String>.from(result);
    } catch (e) {
      return null;
    }
  }

  Future<void> _launchApp(String packageName) async {
    Map<String, String> urlMap = {
      'com.instagram.android':
          'https://www.instagram.com/accounts/login/?next=/accounts/manage_access/',
      'com.snapchat.android':
          'https://accounts.snapchat.com/accounts/login?continue=%2Faccounts%2Fmanage_access',
      'com.facebook.katana': 'fb://settings',
      'com.twitter.android': 'https://twitter.com/settings/account',
      'com.whatsapp': 'https://whatsapp.com'
    };

    String? urlString = urlMap[packageName];
    if (urlString != null) {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        // Handle error
      }
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Scan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: _launchPrivacyCheckup,
                child: Text('Google Account Privacy Checkup'),
              ),
            ),
            const Divider(
              height: 30,
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            ...installedApps.map((app) {
              return ListTile(
                leading: app['icon'] != null
                    ? Image.memory(base64Decode(app['icon']!))
                    : null,
                title: Text('Open ${app['name']} Settings'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => _launchAppSettings(app['package']!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () => _launchApp(app['package']!),
                    ),
                  ],
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}

Future<void> _launchPrivacyCheckup() async {
  const MethodChannel privacyChannel =
      MethodChannel('com.example.spyware/privacy');
  try {
    await privacyChannel.invokeMethod('launchPrivacyCheckup');
  } catch (e) {
    // Handle error
  }
}

Future<void> _launchAppSettings(String package) async {
  const MethodChannel settingsChannel =
      MethodChannel('com.example.spyware/settings');
  try {
    await settingsChannel.invokeMethod('openAppSettings', {'package': package});
  } catch (e) {
    // Handle error
  }
}
