import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:uuid/uuid.dart';

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  if (Platform.isWindows) {
    return;
  }
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

Future<FlutterLocalNotificationsPlugin> initializeNotifications() async {
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Android-inställningar
  var initializationSettingsAndroid = const AndroidInitializationSettings(
      '@mipmap/ic_launcher'); // Eller använd egen ikon: '@drawable/ic_notification'

  // iOS-inställningar
  var initializationSettingsIOS = const DarwinInitializationSettings();

  // Kombinera plattformsinställningar
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  return flutterLocalNotificationsPlugin;
}

class NotificationRepository {
  static NotificationRepository? _instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  // private constructor
  NotificationRepository._(
      {required FlutterLocalNotificationsPlugin
          flutterLocalNotificationsPlugin})
      : _flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin;

// Initialize the notification repository
  static Future<NotificationRepository> initialize() async {
    if (_instance != null) {
      return _instance!;
    }
    await _configureLocalTimeZone();
    final plugin = await initializeNotifications();
    _instance =
        NotificationRepository._(flutterLocalNotificationsPlugin: plugin);
    return _instance!;
  }

  // Scheduling of notifications
  Future<void> scheduleNotification(
      {required String title,
      required String content,
      required DateTime deliveryTime,
      required int id}) async {
    await requestPermissions();

    String channelId = const Uuid()
        .v4(); // id should be unique per message, but contents of the same notification can be updated if you write to the same id
    const String channelName =
        "notifications_channel"; // this can be anything, different channels can be configured to have different colors, sound, vibration, we wont do that here
    String channelDescription =
        "Standard notifications"; // description is optional but shows up in user system settings
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId, channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    // from docs, not sure about specifics

    return await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        content,
        tz.TZDateTime.from(
            deliveryTime,
            tz
                .local), // TZDateTime required to take daylight savings into considerations.
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

// Cancel scheduling of notifications
  Future<void> cancelScheduledNotificaion(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

// Administrate notification access

  Future<void> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  // final NotificationApi _notificationApi = NotificationApi();

  // Future<List<Notification>> getNotifications() async {
  //   return await _notificationApi.getNotifications();
  // }
}
