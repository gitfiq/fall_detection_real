// ignore_for_file: avoid_print, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fall_detection_real/data/user_id.dart';
import 'package:fall_detection_real/firebase_options.dart';
import 'package:fall_detection_real/pages/home_page.dart';
import 'package:fall_detection_real/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Request notification permissions
  await requestNotificationPermissions();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        // Add the delegates for MaterialLocalizations
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        // Add the locales your app supports
        Locale('en', 'US'), // English
        // Add more locales if needed
      ],
      navigatorKey: navigatorKey,
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/homepage') {
          final userId = settings.arguments as UserId?;
          return MaterialPageRoute(
            builder: (context) => HomePage(userId: userId),
          );
        }
        return null; //if there is not routes suggested here, do not generate any
      },
    ),
  );
}

Future<void> requestNotificationPermissions() async {
  // Check if notification permissions are granted
  PermissionStatus permissionStatus = await Permission.notification.status;

  // If permissions are not granted, request them
  if (!permissionStatus.isGranted) {
    PermissionStatus status = await Permission.notification.request();

    // If permission is denied, show a dialog or handle it appropriately
    if (status != PermissionStatus.granted) {
      // Handle the case where permission is not granted
      print('Notification permission denied');
      // Optionally, show a dialog to inform the user
    }
  }
}
