// ignore_for_file: avoid_print

import 'package:fall_detection_real/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'package:fall_detection_real/services/firestore_operations.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final deviceId = inputData?['deviceId'];
    if (deviceId != null) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        await FirestoreOperations().initNotifications(deviceId);
      } catch (error) {
        // Handle the error here (e.g., print it to logs)
        print("Error listening for fall status changes: $error");
      }
    }
    return Future.value(true);
  });
}

Future<void> initializeWorkManager(String deviceId) async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  await Workmanager().registerPeriodicTask(
    "fallStatusMonitoringTask", // Task ID
    "fallStatusMonitoring", // Task Name
    frequency: const Duration(seconds: 15), // Set frequency as needed
    inputData: <String, dynamic>{"deviceId": deviceId}, // Input data
  );

  // Initialize notifications
  await FirestoreOperations().initNotifications(deviceId);
}
