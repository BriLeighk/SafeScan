import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'csv_utils.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// App Name, Color Scheme
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test - Spyware Detector App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 84, 109, 191),
        ),
        useMaterial3: true,
      ),
      home: const MainPage(title: 'SafeScan'),
    );
  }
}

// App Home Page (Title, Description, Spyware Scan Button, Privacy Checkup)
class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 40),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                  child: Text(
                    'SafeScan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                  child: Text(
                    'SafeScan is here to help ensure your digital privacy. This app '
                    'gently checks for any potentially harmful apps on your device '
                    'and guides you on how to best adjust your privacy settings.\n'
                    '\nPlease select an option below to begin:',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 0, bottom: 50),
                  child: Divider(
                    height: 5,
                    thickness: 2,
                    indent: 20,
                    endIndent: 20,
                  ),
                ),
                const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                    child: Text(
                      'Scanning your device will '
                      'alert you of any potentially harmful apps on your device, ranked '
                      'from most to least harmful.',
                      style: TextStyle(fontSize: 14),
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const MyHomePage(title: 'Scan Device'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 60),
                    ),
                    child: const Text('Scan Device'),
                  ),
                ),
                const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                    child: Text(
                      '\nConducting a privacy scan will '
                      'provide you with some popular social media apps on your device '
                      'that may need privacy setting adjustments, and give you the option '
                      'to clear browsing traces.',
                      style: TextStyle(fontSize: 14),
                    )),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyScanPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 60),
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                  ),
                  child: const Text('Privacy Scan'),
                ),
                const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                    child: Text(
                      '\nConducting an ADB Scan allows you to scan your device remotely'
                      ' from an alternate device.',
                      style: TextStyle(fontSize: 14),
                    )),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ADBScanPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 60),
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                  ),
                  child: const Text('ADB Scan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Privacy Scan Page
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class PrivacyScanPage extends StatefulWidget {
  const PrivacyScanPage({super.key});

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
        //print('Could not launch $urlString');
      }
    } else {
      //print('No URL found for $package');
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

class PermissionInfo {
  final String name;
  final IconData icon;
  final String description;

  PermissionInfo(
      {required this.name, required this.icon, required this.description});
}

class PermissionIcon {
  final String permission;

  PermissionIcon({required this.permission});

  // Permission Groups
  IconData getIcon() {
    switch (permission) {
      case "location":
        return Icons.location_on;
      case "camera":
        return Icons.camera_alt;
      case "microphone":
        return Icons.mic;
      case "storage":
        return Icons.folder;
      default:
        return Icons.security; // Default for unknown permissions
    }
  }
}

// App Scan Page
class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('samples.flutter.dev/spyware');
  static const settingsChannel = MethodChannel('com.example.spyware/settings');
  bool _searchPerformed = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _spywareApps = [];

  final List<PermissionInfo> _permissionsInfo = [
    PermissionInfo(
      name: 'Location Sharing',
      icon: Icons.location_on,
      description:
          'Grants access to your active location. While essential for navigation and weather apps, it can serve details such as your home address, routes you’ve taken, and other sensitive information to the apps that enable it. It is best to stay cautious and only enable location sharing if absolutely necessary.',
    ),
    PermissionInfo(
      name: 'Camera',
      icon: Icons.camera_alt,
      description:
          'Grants access to your camera for taking photos and videos. Ensure that each app that enables it has a use for it, such as social media, photography, and editing apps. Other apps, such as music and audio apps, should not require camera enabling.',
    ),
    PermissionInfo(
      name: 'Microphone',
      icon: Icons.mic,
      description:
          'Grants access to your microphone for recording audio. Audio is a powerful tool, and if given to a non-trusted application, can be used to record confidential information. Ensure it is only enabled for trustworthy apps that have a use for it.',
    ),
    PermissionInfo(
      name: 'Files and Media',
      icon: Icons.folder,
      description:
          'Grants access to photo galleries and file managers on the device. By giving apps access to storage, any sensitive information contained on the device can be accessed. It is best to be weary of what apps have this permission enabled, and keep sensitive information stored in an encrypted cloud, instead of on the device.',
    ),
  ];

  Future<void> _getSpywareApps() async {
    setState(() {
      _isLoading = true;
    });

    // Gets list of spyware/dual-use apps detected on device
    List<dynamic> spywareApps;
    try {
      List<List<dynamic>> remoteCSVData = await fetchRemoteCSVData();
      final List<dynamic> result = await platform
          .invokeMethod('getSpywareApps', {"csvData": remoteCSVData});
      spywareApps = result.map((app) {
        return Map<String, dynamic>.from(app.map((key, value) {
          return MapEntry(key.toString(), value);
        }));
      }).toList();
    } catch (e) {
      // Fallback to local CSV data if remote fetch fails
      try {
        List<List<dynamic>> localCSVData = await loadLocalCSVData();
        final List<dynamic> result = await platform
            .invokeMethod('getSpywareApps', {"csvData": localCSVData});
        spywareApps = result.map((app) {
          return Map<String, dynamic>.from(app.map((key, value) {
            return MapEntry(key.toString(), value);
          }));
        }).toList();
      } catch (localException) {
        spywareApps = [
          {
            "id": "Error",
            "name":
                "Failed to get spyware apps: '${localException.toString()}'.",
            "icon": null
          }
        ];
      }
    }

    spywareApps.sort((a, b) => _getSortWeight(a['type'], a['installer'])
        .compareTo(_getSortWeight(b['type'], b['installer'])));

    setState(() {
      _spywareApps = spywareApps.cast<Map<String, dynamic>>();
      _isLoading = false;
      _searchPerformed = true;
    });
  }

  // Adds Bulleted List of Permission Instructions to Top of App Scan Page
  Widget _buildPermissionsInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _permissionsInfo.map((info) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(info.icon, size: 24.0),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(info.description),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _openAppSettings(String package) async {
    try {
      await settingsChannel
          .invokeMethod('openAppSettings', {'package': package});
    } catch (e) {
      //print('Failed to open app settings: $e');
    }
  }

  Color lightColor(Map<String, dynamic> app, String installer, String type) {
    if (app['installer'] != 'com.android.vending') {
      return const Color.fromARGB(255, 255, 177, 177);
    } else {
      if (app['type'] == 'offstore') {
        return const Color.fromARGB(255, 255, 177, 177);
      } else if (app['type'] == 'spyware' || app['type'] == 'Unknown') {
        return const Color.fromARGB(255, 255, 255, 173);
      } else if (app['type'] == 'dual-use') {
        return const Color.fromARGB(255, 175, 230, 255);
      } else {
        return Colors.grey;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const List<String> secureInstallers = [
      'com.android.vending',
      'com.amazon.venezia',
      // Add more secure installers if they exist
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _spywareApps.clear();
                _searchPerformed = false;
                _isLoading = false;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(" Color Key: ",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Dual-use  ",
                    style: TextStyle(
                        backgroundColor: Color.fromARGB(255, 175, 230, 255),
                        fontWeight: FontWeight.bold)),
                Text("Spyware  ",
                    style: TextStyle(
                        backgroundColor: Color.fromARGB(255, 255, 255, 173),
                        fontWeight: FontWeight.bold)),
                Text("Unsecure Download ",
                    style: TextStyle(
                        backgroundColor: Color.fromARGB(255, 255, 177, 177),
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildPermissionsInfo(),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _spywareApps.isEmpty && _searchPerformed
                    ? const Center(
                        child: Text("No spyware apps detected on your device"))
                    : ListView.builder(
                        itemCount: _spywareApps.length,
                        itemBuilder: (context, index) {
                          var app = _spywareApps[index];
                          Color baseColor =
                              lightColor(app, app['installer'], app['type']);
                          List<PermissionIcon> permissions =
                              (app['permissions'] as List<dynamic>? ?? [])
                                  .map((perm) {
                            return PermissionIcon(
                              permission: perm['icon'],
                            );
                          }).toList();
                          return TextButton(
                            onPressed: () async {
                              _openAppSettings(app['id']);
                            },
                            child: Container(
                              margin: const EdgeInsets.all(.1),
                              decoration: BoxDecoration(
                                color: baseColor,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ListTile(
                                tileColor: Colors.transparent,
                                leading: app['icon'] != null
                                    ? Image.memory(
                                        base64Decode(app['icon']?.trim() ?? ''))
                                    : null,
                                title: RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: <TextSpan>[
                                      TextSpan(
                                        text:
                                            '${app['name'] ?? 'Unknown Name'}  ',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: '(${app['id'] ?? 'Unknown ID'})',
                                      ),
                                    ],
                                  ),
                                ),
                                trailing:
                                    secureInstallers.contains(app['installer'])
                                        ? IconButton(
                                            icon: const Icon(Icons.open_in_new),
                                            onPressed: () =>
                                                _launchURL(app['storeLink']),
                                          )
                                        : null,
                                subtitle: Row(
                                  children: permissions.map((permIcon) {
                                    return Icon(permIcon.getIcon(), size: 18.0);
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () async {
            await _getSpywareApps();
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Text('List Detected Spyware Applications'),
        ),
      ),
    );
  }
}

// ADB Scan Page
class ADBScanPage extends StatefulWidget {
  const ADBScanPage({super.key});

  @override
  _ADBScanPageState createState() => _ADBScanPageState();
}

class _ADBScanPageState extends State<ADBScanPage> {
  static const adbChannel = MethodChannel('com.example.spyware/adb');
  bool _isConnected = false;
  bool _isScanning = false;
  String _scanResult = '';
  final TextEditingController _portController = TextEditingController();

  Future<void> _connectToDevice() async {
    try {
      final bool result = await adbChannel.invokeMethod('connectToDevice',
          {'port': int.tryParse(_portController.text) ?? 5555});
      setState(() {
        _isConnected = result;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _scanResult = 'Error connecting to device: $e';
      });
    }
  }

  Future<void> _scanDevice() async {
    if (!_isConnected) return;

    setState(() {
      _isScanning = true;
      _scanResult = 'Scanning...';
    });

    try {
      // Fetch the remote CSV data
      List<List<dynamic>> remoteCSVData = await fetchRemoteCSVData();

      // Perform the scan
      final String result = await adbChannel
          .invokeMethod('scanDevice', {'csvData': remoteCSVData});
      setState(() {
        _scanResult = result;
      });
    } catch (e) {
      setState(() {
        _scanResult = 'Error scanning device: $e';
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADB Scan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Step-by-Step Instructions:'),
            const Text(
                '1. Connect the target device to the source device via USB.'),
            const Text('2. Enable USB debugging on the target device.'),
            const Text(
                '3. Enter the port number and click "Connect to Device".'),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                  labelText: 'Enter Port Number (e.g., 5555)'),
            ),
            ElevatedButton(
              onPressed: _connectToDevice,
              child: const Text('Connect to Device'),
            ),
            if (_isConnected) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isScanning ? null : _scanDevice,
                child: _isScanning
                    ? const CircularProgressIndicator()
                    : const Text('Scan Device'),
              ),
            ],
            const SizedBox(height: 20),
            Text(_scanResult),
          ],
        ),
      ),
    );
  }
}

Future<void> _launchURL(String? urlString) async {
  if (urlString != null) {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      //print('Could not launch $urlString');
    }
  }
}

Future<void> _launchPrivacyCheckup() async {
  const MethodChannel privacyChannel =
      MethodChannel('com.example.spyware/privacy');
  try {
    await privacyChannel.invokeMethod('launchPrivacyCheckup');
  } catch (e) {
    //print('Failed to launch privacy checkup: $e');
  }
}

Future<void> _launchAppSettings(String package) async {
  const MethodChannel settingsChannel =
      MethodChannel('com.example.spyware/settings');
  try {
    await settingsChannel.invokeMethod('openAppSettings', {'package': package});
  } catch (e) {
    //print('Failed to open app settings: $e');
  }
}

int _getSortWeight(String type, String installer) {
  if (installer != 'com.android.vending' && installer != 'com.amazon.venezia') {
    return 1;
  } else {
    if (type == 'offstore') {
      return 2;
    } else if (type == 'spyware' || type == 'Unknown') {
      return 3;
    } else if (type == 'dual-use') {
      return 4;
    } else {
      return 5;
    }
  }
}
