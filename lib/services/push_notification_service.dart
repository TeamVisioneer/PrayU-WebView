import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';

// 플러그인 인스턴스를 전역으로 정의
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
late AndroidNotificationChannel channel;
const String notificationIcon =
    '@mipmap/ic_launcher'; // '@mipmap/ic_launcher'파일을 푸시 아이콘으로 사용합니다.

// 최상위 함수로 백그라운드 메시지 핸들러 정의
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 필요한 초기화 작업 수행
  await _initializeFlutterLocalNotificationsPlugin();
  await _initializeAndroidNotificationChannel();

  var notification = message.notification;
  var android = message.notification?.android;

  if (notification != null && android != null) {
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          icon: notificationIcon,
          importance: Importance.high,
        ),
      ),
    );
  }
}

// 플러그인 초기화
Future<void> _initializeFlutterLocalNotificationsPlugin() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(notificationIcon);
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// 안드로이드 알림 채널 초기화
Future<void> _initializeAndroidNotificationChannel() async {
  final packageInfo = await PackageInfo.fromPlatform();
  final packageName = packageInfo.packageName;

  // 안드로이드 알림 채널 설정
  channel = AndroidNotificationChannel(
    packageName,
    'notification',
    importance: Importance.high,
  );

  // 안드로이드용 알림 채널 생성
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

class FPPushNotificationService {
  FPPushNotificationService() {
    _initializeFlutterLocalNotificationsPlugin();
  }

  // 알림 권한 요청 메서드
  Future<void> requestPermission() {
    return FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  // 현재 알림 권한 상태를 가져오는 메서드
  Future<bool?> hasPermission() async {
    var settings = await FirebaseMessaging.instance.getNotificationSettings();
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        return true;
      case AuthorizationStatus.notDetermined:
        // iOS에만 존재하는 상태. iOS는 Push 권한을 나중에 받지만 Android는 Manifest에서 받기 때문에 true/false로만 반환
        return null;
      default:
        return false;
    }
  }

  // 현재 FCM 토큰을 가져오는 메서드
  Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  // 알림 초기화 메서드
  Future<void> initializeNotification(
      {required Function(String? fcmToken) updatedTokenHandler}) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _initializeAndroidNotificationChannel();

    // 포그라운드 메시지 수신 리스너 설정
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      var notification = message.notification;
      var android = message.notification?.android;

      if (notification != null && android != null) {
        await _showLocalNotification(notification); // 로컬 알림 표시
      }
    });

    // 백그라운드 메시지 핸들러 설정
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 초기 FCM 토큰 및 토큰 갱신 핸들러 설정
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await updatedTokenHandler(token);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen(updatedTokenHandler);
  }

  // 로컬 알림 표시 메서드
  Future<void> localNotification(
      {int id = 0, required String? title, required String? body}) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          icon: notificationIcon,
          importance: Importance.high,
        ),
      ),
    );
  }

  // 로컬 알림을 표시하는 내부 메서드
  Future<void> _showLocalNotification(RemoteNotification notification) async {
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          icon: notificationIcon,
          importance: Importance.high,
        ),
      ),
    );
  }
}
