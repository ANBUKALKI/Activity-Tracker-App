import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/src/screen/auth_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:tracker_app/src/screen/dashboard_screen.dart';
import 'package:tracker_app/src/screen/login_screen.dart';
import 'package:tracker_app/src/screen/permissions_screen.dart';
import 'package:tracker_app/src/screen/splash_screen.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp( DevicePreview(
      enabled: true,
      builder: (context)=> const MyApp()
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'Activity Tracker App',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth' : (context) =>  AuthWrapper(),
        '/login' : (context) => const LoginScreen(),
        '/permissions' : (context) => const PermissionsScreen() ,
        '/dashboard' : (context) => const DashboardScreen(),
      },
    );
  }
}
