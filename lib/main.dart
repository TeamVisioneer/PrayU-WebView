import 'package:flutter/material.dart';
import 'package:prayu_webview/views/home_screen.dart';
import 'package:prayu_webview/utils/local_notification/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    ),
  );
}
