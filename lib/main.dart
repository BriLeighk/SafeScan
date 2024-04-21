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
      home: const MyHomePage(title: 'Trial - Spyware App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // Home Page

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Home Page

  static const platform = MethodChannel('samples.flutter.dev/spyware');
  // initialize method channel to correspond with native languages
  List<Map<String, dynamic>> _spywareApps = []; //to store all detected spyware

  Future<void> _getSpywareApps() async {
    List<dynamic> spywareApps;
    try {
      final List<dynamic> result =
          await platform.invokeMethod('getSpywareApps'); //access method channel
      spywareApps = result.map((app) {
        return Map<String, String>.from(app.map((key, value) {
          return MapEntry(key.toString(), value.toString());
        }));
      }).toList(); //store result (since result is final)
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
      // cast list from dynamic to string type.
    });
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
              });
            },
          ),
        ],
      ),
      body: _spywareApps.isEmpty //if list is empty, no spyware apps detected,
          ? const Center(child: Text("No spyware apps detected on your device"))
          : ListView.builder(
              //otherwise, build the list view and display it.
              itemCount: _spywareApps.length,
              itemBuilder: (context, index) {
                var app = _spywareApps[index];
                return ListTile(
                    leading: app['icon'] != null
                        ? Image.memory(base64Decode(app['icon']?.trim() ?? ''))
                        : null, // Displays the icon for the app if it's not null
                    title: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                            text: '${app['name'] ?? 'Unknown Name'}  ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '(${app['id'] ?? 'Unknown ID'})',
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AppDetailPage(appData: app),
                      ));
                    });
              },
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

class AppDetailPage extends StatelessWidget {
  final Map<String, dynamic> appData;

  const AppDetailPage({super.key, required this.appData});

  static const platform = MethodChannel('com.example.spyware/settings');

  Future<void> _openAppSettings(String package) async {
    try {
      await platform.invokeMethod('openAppSettings', {'package': package});
    } catch (e) {
      print('Failed to open app settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Details'),
      ),
      body: Column(
        children: <Widget>[
          // Your existing widgets...
          ElevatedButton(
            onPressed: () => _openAppSettings(appData['id']),
            child: const Text('Delete App in App Settings'),
          )
        ],
      ),
    );
  }
}
