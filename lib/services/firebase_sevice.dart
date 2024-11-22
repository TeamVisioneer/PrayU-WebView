import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

String? fcmToken;

Future<void> initFirebaseAndLocalNotifications() async {
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  const AndroidNotificationChannel androidNotificationChannel =
      AndroidNotificationChannel(
    'high_priority_channel',
    'High Priority Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  // 알림 채널 생성
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidNotificationChannel);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/notification_icon');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // APNs 토큰 가져오기 시도
  String? apnsToken;
  if (Platform.isIOS) {
    for (int attempt = 0; attempt < 3; attempt++) {
      apnsToken = await messaging.getAPNSToken();
      if (apnsToken != null) {
        break;
      }
      //print("Attempt $attempt: APNs token not available yet, retrying in 2 seconds...");
      await Future.delayed(Duration(seconds: 2));
    }

    if (apnsToken == null) {
      //print("Failed to retrieve APNs token after multiple attempts. Please check APNs configuration.");
    } else {
      //print("APNs token retrieved successfully: $apnsToken");
    }

    fcmToken = await messaging.getToken();
  }

  fcmToken = await messaging.getToken();
}

Future<void> showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'high_priority_channel', // 채널 ID와 일치하도록 설정
    'High Priority Notifications', // 채널 이름과 일치하도록 설정
    channelDescription:
        'This channel is used for important notifications.', // 알림 채널 설명
    icon: '@drawable/notification_icon',
    importance: Importance.max,
    priority: Priority.high,
  );

  const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails();

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title ?? 'No Title',
    message.notification?.body ?? 'No Body',
    platformChannelSpecifics,
  );
}

Future<void> onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  //print('iOS Local Notification: $title - $body');
}

void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) {
  //final String? payload = notificationResponse.payload;
  //print('Notification payload: $payload');
}

void setupFirebaseMessagingListeners() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      showNotification(message);
    }
  });
}
