import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:prayu_webview/views/home_screen.dart';
import 'package:prayu_webview/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: '57583aa0c3464bf71e902b9c78580e5b',
    javaScriptAppKey: '8cec546a8802b8b706beb1ffb28b0c8a',
  );
  await NotificationService.init();
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  FirebaseApp _firebaseApp = await Firebase.initializeApp();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    ),
  );
}
