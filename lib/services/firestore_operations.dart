// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fall_detection_real/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirestoreOperations {
  //Getting the instance of the FirebaseFirestore
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  //Create instance if Firebase Messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  //function to initialize notification
  Future<void> initNotifications(String deviceId) async {
    //request permission from user
    await _firebaseMessaging.requestPermission();

    //fetch FCM token for the device
    // ignore: non_constant_identifier_names
    final FCMToken = await _firebaseMessaging.getToken();
    print("Token: $FCMToken");

    // Subscribe to falldetect topic if user's unique ID exists
    final userDoc = await users.doc(deviceId).get();
    if (userDoc.exists) {
      await _firebaseMessaging.subscribeToTopic('detectfall');

      //initialize further settings for push notification
      initPushNotifications();

      // Register background message handler
      registerBackgroundMessageHandler();
    } else {
      // Handle case where unique ID does not exist
      print('User ID does not exist');
    }
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

    //handle notification if app was terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    //attach event listeners for when a notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
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
}
