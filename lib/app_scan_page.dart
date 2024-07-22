import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spyware/csv_utils.dart';
import 'package:url_launcher/url_launcher.dart';

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
        return Icons.security;
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.scanTarget});

  final String title;
  final bool scanTarget;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

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

  List<Widget> _buildPermissionsInfo() {
    return _permissionsInfo.map((PermissionInfo info) {
      return ExpansionTile(
        leading: Icon(info.icon),
        title: Text(info.name),
        children: <Widget>[
          ListTile(
            title: Text(info.description),
          ),
        ],
      );
    }).toList();
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
            child: Column(
              children: _buildPermissionsInfo(),
            ),
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
