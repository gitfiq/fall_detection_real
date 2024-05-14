// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fall_detection_real/data/user_id.dart';
import 'package:fall_detection_real/firebase_options.dart';
import 'package:fall_detection_real/pages/home_page.dart';
import 'package:fall_detection_real/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
