// main.dart
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prayu_webview/services/firebase_sevice.dart';
import 'package:prayu_webview/views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FacebookAppEvents();

  await Firebase.initializeApp();
  await initFirebaseAndLocalNotifications();
  setupFirebaseMessagingListeners();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    ),
  );
}
