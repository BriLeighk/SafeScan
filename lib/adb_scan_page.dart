// ADB Scan Page
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spyware/csv_utils.dart';

// ADB Scan Page
// TODO: implement tester version of ADB functionality
// convert to button on upper-left of main page (with modal to connect devices)
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
