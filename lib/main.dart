// main.dart
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:prayu_webview/services/firebase_sevice.dart';
import 'package:prayu_webview/views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: '57583aa0c3464bf71e902b9c78580e5b',
    javaScriptAppKey: '8cec546a8802b8b706beb1ffb28b0c8a',
  );

  await initFirebaseAndLocalNotifications();

  setupFirebaseMessagingListeners();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    ),
  );
}
