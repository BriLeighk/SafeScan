import 'package:flutter/material.dart';
import 'adb_connect_page.dart';
import 'app_scan_page.dart';
import 'privacy_scan_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isConnected = false;

  void _updateConnectionStatus(bool status) {
    setState(() {
      _isConnected = status;
    });
  }

  void _performScan({required bool scanTarget}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          title: scanTarget ? 'Scan Target Device' : 'Scan Source Device',
          scanTarget: scanTarget,
        ),
      ),
    );
  }

  void _performPrivacyScan({required bool scanTarget}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrivacyScanPage(scanTarget: scanTarget),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.usb),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ADBConnectPage(),
                ),
              );
              if (result != null) {
                _updateConnectionStatus(result);
              }
            },
          ),
        ],
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
                    onPressed: _isConnected
                        ? () => _performScan(scanTarget: true)
                        : () => _performScan(scanTarget: false),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 60),
                    ),
                    child: Text(
                        _isConnected ? 'Target: Scan Device' : 'Scan Device'),
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
                  onPressed: _isConnected
                      ? () => _performPrivacyScan(scanTarget: true)
                      : () => _performPrivacyScan(scanTarget: false),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 60),
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                  ),
                  child: Text(
                      _isConnected ? 'Target: Privacy Scan' : 'Privacy Scan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
