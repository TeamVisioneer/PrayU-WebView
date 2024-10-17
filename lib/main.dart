// main.dart
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:prayu_webview/services/firebase_sevice.dart';
import 'package:prayu_webview/views/home_screen.dart';
import 'package:prayu_webview/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: '57583aa0c3464bf71e902b9c78580e5b',
    javaScriptAppKey: '8cec546a8802b8b706beb1ffb28b0c8a',
  );

  await Supabase.initialize(
    url: 'https://cguxpeghdqcqfdhvkmyv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNndXhwZWdoZHFjcWZkaHZrbXl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjAwMTc1ODksImV4cCI6MjAzNTU5MzU4OX0.iigkNF_b8t2W-dV-ZBWzBf06G6uSWnuT6jI6xoRCWO8',
  );

  // 민수 알림
  await NotificationService.init();

  await initFirebaseAndLocalNotifications();

  setupFirebaseMessagingListeners();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    ),
  );
}
