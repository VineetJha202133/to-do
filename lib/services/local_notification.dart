import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  LocalNotification().handleMessage(message);
}

class LocalNotification {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static initLocalPlugin() async {
    tz.initializeTimeZones();
    _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    await createNotificationChannel("default_notification_channel_id",
        "High Importance Notifications");

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings("@mipmap/ic_launcher");
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestCriticalPermission: true,
        requestProvisionalPermission: true,
        requestSoundPermission: true,
        defaultPresentBadge: true);
    const InitializationSettings initializationSettings =
    InitializationSettings(android: androidSettings, iOS: iosSettings);
    log("Local message initialize", name: "localNoti class");
    _notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          log("===>${response.payload.toString()}",
              name: "onDidReceiveNotificationResponse");
        });
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        LocalNotification().handleMessage(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      LocalNotification().handleMessage(message);
    });
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    // Handle the message here
    log("Message received: ${message.notification?.title}, ${message.notification?.body}");
  }

  static scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        "default_notification_channel_id", "High Importance Notifications",
        playSound: true,
        priority: Priority.max,
        setAsGroupSummary: true,
        importance: Importance.max);
    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
        interruptionLevel: InterruptionLevel.timeSensitive);
    NotificationDetails notiDetails =
    NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notiDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    log('Scheduled notification for $scheduledDate in timezone ${tz.local}');
  }

  static showNotification(
      {String? title = "Sol", String? disc = "New notification found"}) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        "default_notification_channel_id", "High Importance Notifications",
        playSound: true,
        priority: Priority.max,
        setAsGroupSummary: true,
        importance: Importance.max);
    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
        interruptionLevel: InterruptionLevel.timeSensitive);
    NotificationDetails notiDetails =
    NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notificationsPlugin.show(id, "$title", "$disc", notiDetails);
  }

  static createNotificationChannel(String id, String name) async {
    var androidNotificationChannel = AndroidNotificationChannel(id, name,
        playSound: true,
        showBadge: true,
        importance: Importance.max);
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }
  static cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
