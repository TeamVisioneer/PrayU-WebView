import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

String? fcmToken;

Future<void> initFirebaseAndLocalNotifications() async {
  await Firebase.initializeApp();

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
  fcmToken = await messaging.getToken();
}

// TODO: 안드로이드 채널 id, name 추가
Future<void> showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id', // 알림 채널 ID
    'your_channel_name', // 알림 채널 이름
    channelDescription: 'your_channel_description', // 알림 채널 설명
    icon: 'notification_icon', // 여전히 작은 아이콘은 투명한 아이콘을 사용
    largeIcon: DrawableResourceAndroidBitmap('large_icon'),
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
  print('iOS Local Notification: $title - $body');
}

void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) {
  final String? payload = notificationResponse.payload;
  print('Notification payload: $payload');
}

void setupFirebaseMessagingListeners() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      showNotification(message);
    }
  });
}
