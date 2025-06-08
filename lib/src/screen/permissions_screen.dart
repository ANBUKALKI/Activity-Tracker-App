import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({Key? key}) : super(key: key);

  Future<void> _requestCallLogPermission(BuildContext context) async {
    final status = await Permission.phone.request();
    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Call log permission granted')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied')),
      );
      await openAppSettings();
    }
  }

  Future<void> _enableAccessibilityService(BuildContext context) async {
    try {
      const platform = MethodChannel('com.example.tracker_app/accessibility');
      await platform.invokeMethod('openAccessibilitySettings');
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open settings: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'To begin tracking, please enable Accessibility Services and Call log permission.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () => _enableAccessibilityService(context),
              child: const Text('Enable Accessibility Service'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => _requestCallLogPermission(context),
              child: const Text('Enable Call Logs'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
              child: const Text('Continue to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
