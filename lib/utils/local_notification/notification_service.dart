import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static NotificationDetails get _notificationDetails =>
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          "1",
          "test",
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

  // NotificationService() {
  //   tz.initializeTimeZones();
  //   tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
  // }

  // 알림 초기화
  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    AndroidInitializationSettings android =
        const AndroidInitializationSettings("@drawable/notification_icon");
    DarwinInitializationSettings ios = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    InitializationSettings settings =
        InitializationSettings(android: android, iOS: ios);

    await _localNotificationsPlugin.initialize(settings);
    await requestNotificationPermissions();
    //await showNotification();
    //await PeriodicNotification();
    await scheduleDailyNotification(
      0,
      20,
      9,
      "PrayU",
      "오늘도 기도로 하루를 마무리 해볼까요 😊",
    );
  }

  // 권한 요청
  static Future<void> requestNotificationPermissions() async {
    if (await Permission.notification.isDenied &&
        !await Permission.notification.isPermanentlyDenied) {
      await [Permission.notification].request();
    }
  }

  // 알림 표시
  static Future<void> showNotification() async {
    await _localNotificationsPlugin.show(
      1, // 알림 ID
      "PrayU", // 알림 제목
      "대문😊", // 알림 내용
      _notificationDetails, // 알림 설정
    );
  }

  static Future<void> PeriodicNotification() async {
    await _localNotificationsPlugin.periodicallyShow(
      2,
      "PrayU",
      "귀찮지>?",
      RepeatInterval.everyMinute,
      _notificationDetails,
    );
  }

  // 매일 같은 시간에 알림 스케줄링
  static Future<void> scheduleDailyNotification(
      int id, int hour, int minute, String title, String body) async {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime schedule =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // 알림 시간에 오늘 시간이 지난 경우 다음 날로 설정
    if (schedule.isBefore(now)) {
      schedule = schedule.add(Duration(days: 1));
    }

    await _localNotificationsPlugin.zonedSchedule(
      id, // 알림 ID
      title,
      body,
      schedule,
      _notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 동일한 시간에 알림 실행
    );
  }
}
