// ignore_for_file: avoid_print, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fall_detection_real/firebase_options.dart';
import 'package:fall_detection_real/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:workmanager/workmanager.dart';

class FirestoreOperations {
  //Getting the instance of the FirebaseFirestore
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //Initiate the local notification settings
  Future<void> initLocalNotifications() async {
    //Initialize thee basic notification
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  //show local notification
  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'fall_detection_channel',
      'Fall Detection Notifications',
      channelDescription: 'Notifications for fall detection',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  void startListeningForFallStatusChanges(String deviceId) {
    users.doc(deviceId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>?;
        if (data != null && data['fall_status'] == true) {
          // Read username from Firestore
          users.doc(deviceId).get().then((userDoc) {
            if (userDoc.exists) {
              String username = userDoc.get('username');

              // Show local notification
              //Checks if user puts a username already or not
              if (username.isEmpty) {
                //Show notification with deviceID
                showNotification('Fall Detected',
                    'A fall has been detected for device ID $deviceId');
              } else {
                //Show notification with username
                showNotification(
                    'Fall Detected', 'A fall has been detected for $username');
              }
            }
          });
        }
      }
    });
  }

  //Create instance if Firebase Messaging
  //final _firebaseMessaging = FirebaseMessaging.instance;
  // final TwilioFlutter twilioFlutter = TwilioFlutter(
  //   accountSid: 'ACc7bdd034ea8d53397fc87939be6828a2',
  //   authToken: 'e63911e255496e14ff92c8cd4eaedc8d',
  //   twilioNumber: '+12252636312',
  // );

  //function to initialize notification
  Future<void> initNotifications(String deviceId) async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.requestPermission();

    await initLocalNotifications();

    // Subscribe to fall detection changes
    startListeningForFallStatusChanges(deviceId);

    //initialize further settings for push notification
    initPushNotifications();
    // Register background message handler
    registerBackgroundMessageHandler();

    //Subsribe to the topic of the push notification
    await subscribeToTopic(deviceId);

    // //request permission from user
    // await _firebaseMessaging.requestPermission();
    // //fetch FCM token for the device
    // // ignore: non_constant_identifier_names
    // final FCMToken = await _firebaseMessaging.getToken();
    // print("Token: $FCMToken");

    // // Subscribe to falldetect topic if user's unique ID exists
    // final userDoc = await users.doc(deviceId).get();
    // if (userDoc.exists) {
    //   // _startListeningForFallStatusChanges(deviceId);
    //   // await _firebaseMessaging.subscribeToTopic('detectfall');

    //   //initialize further settings for push notification
    //   initPushNotifications();
    //   // Register background message handler
    //   registerBackgroundMessageHandler();
    // } else {
    //   // Handle case where unique ID does not exist
    //   print('User ID does not exist');
    // }
  }

  //Handle message upon notification
  void handleMessage(RemoteMessage? message) {
    //if message null, do nothing
    if (message == null) return;
    //navigate to Login page
    navigatorKey.currentState?.pushNamed("/login");
  }

  //Function to initialize background settings
  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    // //handle notification if app was terminated and now opened
    // FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    // //attach event listeners for when a notification opens the app
    // FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message.notification?.title ?? 'No Title',
          message.notification?.body ?? 'No Body');
    });
  }

  // Register the background message handler
  void registerBackgroundMessageHandler() {
    FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
  }

  // Background message handler function
  Future<void> backgroundMessageHandler(RemoteMessage message) async {
    // Handle the background message here
    print("Handling a background message: ${message.messageId}");
    handleMessage(message);
  }

  // Future<void> updateFcmToken(String deviceId) async {
  //   //initialize further settings for push notification
  //   initPushNotifications();
  //   // Register background message handler
  //   registerBackgroundMessageHandler();

  //   final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  //   firebaseMessaging.requestPermission();

  //   final String? fcmToken = await firebaseMessaging.getToken();
  //   if (fcmToken != null) {
  //     await users.doc(deviceId).update({'fcm_token': fcmToken});
  //     print("FCM Token updated: $fcmToken");
  //   }

  //   await subscribeToTopic(deviceId);
  // }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    print("Subscribed to topic: $topic");
  }

  // // Listen for changes in the fall_status field
  // void _startListeningForFallStatusChanges(String deviceId) {
  //   users.doc(deviceId).snapshots().listen((snapshot) {
  //     if (snapshot.exists) {
  //       var data = snapshot.data() as Map<String, dynamic>?;
  //       if (data != null && data['fall_status'] == true) {
  //         var phoneNumber = data['phone_number'];
  //         if (phoneNumber != null) {
  //           sendSmsNotification(
  //               phoneNumber, 'Alert: Fall detected! for $deviceId');
  //         } else {
  //           print('Phone number is null');
  //         }
  //       }
  //     }
  //   });
  // }

  // // Sends SMS
  // Future<void> sendSmsNotification(String phoneNumber, String message) async {
  //   try {
  //     await twilioFlutter.sendSMS(
  //       toNumber: phoneNumber,
  //       messageBody: message,
  //     );
  //     print('SMS sent to $phoneNumber');
  //   } catch (error) {
  //     print('Failed to send SMS: $error');
  //   }
  // }

  //Stream all the Fall History data from Firestore
  Stream<QuerySnapshot> getFallDocumentsStream(String deviceId) {
    return FirebaseFirestore.instance
        .collection(deviceId)
        .orderBy('time', descending: true)
        .snapshots();
  }

  //Stream the document containing the Overall Status of the user from Firestore
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(
      String deviceId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(deviceId)
        .snapshots();
  }

  //Delete a fall history if a false positive is detected
  Future<void> deleteFallDocument(String deviceId, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection(deviceId)
          .doc(documentId)
          .delete();
    } catch (error) {
      throw Exception("Failed to delete fall document: $error");
    }
  }

  // Function to update device name set by user
  Future<void> updateUserInput(String deviceId, String userInput) async {
    try {
      // Update the document with the specified device ID
      await users.doc(deviceId).update({'username': userInput});
      print('User input updated successfully for device ID: $deviceId');
    } catch (error) {
      print('Error updating user input: $error');
      // Handle error appropriately
    }
  }
}
