import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ADBConnectPage extends StatefulWidget {
  @override
  _ADBConnectPageState createState() => _ADBConnectPageState();
}

class _ADBConnectPageState extends State<ADBConnectPage> {
  static const platform = MethodChannel('com.example.spyware/adb');
  bool _isConnected = false;

  Future<void> _connectDevices() async {
    bool isConnected;
    try {
      final bool result = await platform.invokeMethod('connectToDevice');
      isConnected = result;
    } catch (e) {
      isConnected = false;
    }

    setState(() {
      _isConnected = isConnected;
    });

    if (_isConnected) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect devices')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect Devices'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _connectDevices,
          child: Text('Connect'),
        ),
      ),
    );
  }
}
