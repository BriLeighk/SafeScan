import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test - Spyware Detector App', //title of app
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            //color scheme of entire app
            seedColor: const Color.fromARGB(255, 84, 109, 191)),
        useMaterial3: true,
      ),
      // Title Displayed on App
      home: const MainPage(title: 'Trial - Spyware App'),
    );
  }
}

// NEW HOME PAGE
class MainPage extends StatefulWidget {
  // Main Home Page
  const MainPage({super.key, required this.title});

  // Main Home Page

  final String title; //possibly change this

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Main Home Page State
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.start, // Adjust vertical alignment
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 40), // Increase space at the top
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Text(
                'Spyware Detection Software',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Text(
                'Choose an option below to begin:',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 20.0), // Increased vertical padding
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MyHomePage(title: 'Scan Device')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 60), // Adjust size as needed
                ),
                child: const Text('Scan Device'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyScanPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60), // Adjust size as needed
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0), // Increase padding
              ),
              child: const Text('Privacy Scan'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // App Scan Home Page
  const MyHomePage({super.key, required this.title});

  // Home Page

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class PrivacyScanPage extends StatelessWidget {
  // Privacy Scan Home Page
  const PrivacyScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Scan'),
      ),
      body: const Center(
        child: Text('Privacy Scan Functionality Coming Soon!'),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  // App Scan Home Page State
  //Home Page
  bool _searchPerformed = false;
  bool _isLoading = false; // Indicator to track loading state

  static const platform = MethodChannel('samples.flutter.dev/spyware');
  // initialize method channel to correspond with native languages
  List<Map<String, dynamic>> _spywareApps = []; //to store all detected spyware

  Future<void> _getSpywareApps() async {
    setState(() {
      _isLoading = true; // Start loading phase
    });

    List<dynamic> spywareApps;
    try {
      final List<dynamic> result =
          await platform.invokeMethod('getSpywareApps'); //access method channel
      spywareApps = result.map((app) {
        return Map<String, String>.from(app.map((key, value) {
          return MapEntry(key.toString(), value.toString());
        }));
      }).toList(); //store result (since result is final)
      spywareApps.sort((a, b) => _getSortWeight(a['type'], a['installer'])
          .compareTo(_getSortWeight(b['type'], b['installer'])));
    } on PlatformException catch (e) {
      spywareApps = [
        {
          "id": "Error",
          "name": "Failed to get spyware apps: '${e.message}'.",
          "icon": null
        }
      ];
    }

    setState(() {
      _spywareApps = spywareApps.cast<Map<String, dynamic>>();
      _isLoading = false; // Stop loading once scan is complete
      _searchPerformed = true;
      // cast list from dynamic to string type.
    });
  }

  static const settingsPlatform = MethodChannel('com.example.spyware/settings');

  Future<void> _openAppSettings(String package) async {
    try {
      await settingsPlatform
          .invokeMethod('openAppSettings', {'package': package});
    } catch (e) {
      //print('Failed to open app settings: $e');
    }
  }

  //Widget for homepage
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _spywareApps.clear(); // Only clear the current list on screen
                _searchPerformed = false;
                _isLoading = false; // Ensures loading is reset on refresh
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(8.0),
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
                Text("Unsecure Download  ",
                    style: TextStyle(
                        backgroundColor: Color.fromARGB(255, 255, 177, 177),
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show loading indicator
                : _spywareApps.isEmpty &&
                        _searchPerformed //if list is empty, no spyware apps detected,
                    ? const Center(
                        child: Text("No spyware apps detected on your device"))
                    : ListView.builder(
                        //otherwise, build the list view and display it.
                        itemCount: _spywareApps.length,
                        itemBuilder: (context, index) {
                          var app = _spywareApps[index];
                          Color bgColor =
                              Colors.transparent; //Default no background

                          if (app['installer'] != 'com.android.vending') {
                            bgColor = const Color.fromARGB(
                                255, 255, 177, 177); //unsecure
                          } else {
                            if (app['type'] == 'offstore') {
                              bgColor =
                                  const Color.fromARGB(255, 255, 177, 177);
                            } else if (app['type'] == 'spyware' ||
                                app['type'] == 'Unknown') {
                              bgColor =
                                  const Color.fromARGB(255, 255, 255, 173);
                            } else if (app['type'] == 'dual-use') {
                              bgColor =
                                  const Color.fromARGB(255, 175, 230, 255);
                            }
                          }

                          return ListTile(
                              tileColor: bgColor,
                              leading: app['icon'] != null
                                  ? Image.memory(
                                      base64Decode(app['icon']?.trim() ?? ''))
                                  : null, // Displays the icon for the app if it's not null
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
                              onTap: () => _openAppSettings(app['id']));
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _getSpywareApps,
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context)
                .colorScheme
                .primary, // Use the onPrimary color for text/icon color
          ), // This button continues to initiate the scan
          child: const Text('List Detected Spyware Applications'),
        ),
      ),
    );
  }
}

int _getSortWeight(String type, String installer) {
  if (installer != 'com.android.vending') {
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

// NOT IN USE ///////////////////////////////
class AppDetailPage extends StatelessWidget {
  // App Details Page (DISCONTINUED)
  final Map<String, dynamic> appData;

  const AppDetailPage({super.key, required this.appData});

  static const platform = MethodChannel('com.example.spyware/settings');

  Future<void> _openAppSettings(String package) async {
    try {
      await platform.invokeMethod('openAppSettings', {'package': package});
    } catch (e) {
      //print('Failed to open app settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Casting permissions into a List of Strings
    List<String> permissions = [];
    if (appData['permissions'] is List) {
      permissions = List<String>.from(appData['permissions']);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Details'),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text(appData['name']),
            subtitle: Text('App ID: ${appData['id']}'),
            trailing: const Icon(Icons.security),
          ),
          Expanded(
            child: permissions.isNotEmpty
                ? ListView.builder(
                    itemCount: permissions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Permission: ${permissions[index]}'),
                        leading: Icon(_getPermissionIcon(permissions[index])),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                        "This app currently doesn't have any permissions enabled.")),
          ),
          ElevatedButton(
            onPressed: () => _openAppSettings(appData['id']),
            child: const Text('Delete App in App Settings'),
          )
        ],
      ),
    );
  }

  IconData _getPermissionIcon(String permission) {
    switch (permission) {
      case 'Camera':
        return Icons.camera_alt;
      case 'Location':
        return Icons.location_on;
      case 'Contacts':
        return Icons.contacts;
      case 'Phone':
        return Icons.phone;
      case 'Microphone':
        return Icons.mic;
      case 'SMS':
        return Icons.message;
      case 'Calendar':
        return Icons.calendar_today;
      case 'Body sensors':
        return Icons.favorite;
      case 'Call logs':
        return Icons.call;
      case 'Files':
        return Icons.folder;
      case 'Music and audio':
        return Icons.music_note;
      case 'Nearby devices':
        return Icons.devices_other;
      case 'Notifications':
        return Icons.notifications;
      case 'Photos and videos':
        return Icons.photo;
      case 'Physical activity':
        return Icons.directions_run;
      default:
        return Icons
            .help_outline; // A default icon for permissions not explicitly handled
    }
  }
}
/////////////////////////////////////////////