// main.dart
import 'package:flutter/material.dart';
import 'package:prayu_webview/services/firebase_sevice.dart';
import 'package:prayu_webview/views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initFirebaseAndLocalNotifications();
  setupFirebaseMessagingListeners();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    ),
  );
}
