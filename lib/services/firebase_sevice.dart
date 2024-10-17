import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

String? fcmToken;

// Firebase 및 로컬 알림 초기화 함수
Future<void> initFirebaseAndLocalNotifications() async {
  // Firebase 초기화
  await Firebase.initializeApp();

  // 로컬 알림 초기화(Android & iOS)
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: onDidReceiveLocalNotification, // 알림 수신 처리
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        onDidReceiveNotificationResponse, // 알림 선택 시 동작
  );

  // FCM 권한 요청
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  fcmToken = await messaging.getToken();
  print('FCM Token: $fcmToken');
  print('User granted permission: ${settings.authorizationStatus}');
}

// Firebase 푸시 메시지 수신 시 알림을 표시하는 함수
Future<void> showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id', // 알림 채널 ID
    'your_channel_name', // 알림 채널 이름
    channelDescription: 'your_channel_description', // 알림 채널 설명
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

// iOS: 알림 수신 시 처리
Future<void> onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  print('iOS Local Notification: $title - $body');
}

// 알림을 선택했을 때 처리
void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) {
  final String? payload = notificationResponse.payload;
  print('Notification payload: $payload');
}

// FCM 메시지 리스너 설정
void setupFirebaseMessagingListeners() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    if (message.notification != null) {
      print(
          'Message also contained a notification: ${message.notification!.title}');
      showNotification(message); // 알림 표시
    }
  });
}
