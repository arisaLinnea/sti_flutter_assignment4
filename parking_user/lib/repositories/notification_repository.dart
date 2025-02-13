import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:parking_user/firebase_options.dart';
import 'package:shared_client/shared_client.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

const String iosCategoryIdentifier = 'test_notification';
const String actionId1 = 'id_1min';
const String actionId2 = 'id_20min';
const String actionId3 = 'id_notification';
const String actionId4 = 'id_notification_text';

// will be triggered when app is open in foreground
// Future<void> onDidReceiveNotificationResponse(
//     NotificationResponse notificationResponse) async {
//   if (notificationResponse.payload != null) {
//     if (notificationResponse.actionId == actionId1) {
//       extendParkingTime(
//           1, notificationResponse.payload!, notificationResponse.id!);
//     } else if (notificationResponse.actionId == actionId2) {
//       extendParkingTime(
//           20, notificationResponse.payload!, notificationResponse.id!);
//     } else if (notificationResponse.actionId == actionId3) {
//       updateExistingNotification(
//           notificationResponse.id!, notificationResponse.payload!);
//     }
//   }
// }

// will be triggered when app is open in background
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.payload != null) {
    if (notificationResponse.actionId == actionId1) {
      extendParkingTime(
          1, notificationResponse.payload!, notificationResponse.id!);
    } else if (notificationResponse.actionId == actionId2) {
      extendParkingTime(
          20, notificationResponse.payload!, notificationResponse.id!);
    } else if (notificationResponse.actionId == actionId3) {
      updateExistingNotification(
          notificationResponse.id!, notificationResponse.payload!);
    } else if (notificationResponse.actionId == actionId4) {
      updateExistingNotification(notificationResponse.id!,
          notificationResponse.payload!, notificationResponse.input);
    }
  }
}

// Extend parking time
Future<void> extendParkingTime(
    int minutes, String parkingId, int notificationId) async {
  await dotenv.load(fileName: "../.env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ParkingRepository parkingRepository = ParkingRepository();
  Parking? parking = await parkingRepository.getElementById(id: parkingId);
  if (parking == null) {
    return;
  }
  DateTime newEndTime = DateTime.now().add(Duration(minutes: minutes));
  parking.endTime = newEndTime;
  await parkingRepository.update(id: parkingId, item: parking);

  //set new notification
  NotificationRepository notificationRepository =
      await NotificationRepository.initialize();

  await notificationRepository.scheduleNotification(
      id: notificationId,
      title: 'Parking expiration',
      content: 'Parking at ${parking.parkinglot?.address.toString()}',
      deliveryTime: newEndTime.subtract(const Duration(seconds: 45)),
      parkingId: parkingId);
}

Future<void> updateExistingNotification(int notificationId, String parkingId,
    [String? message]) async {
  await dotenv.load(fileName: "../.env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ParkingRepository parkingRepository = ParkingRepository();
  Parking? parking = await parkingRepository.getElementById(id: parkingId);
  if (parking == null) {
    return;
  }
  if (parking.endTime!
      .isBefore(DateTime.now().add(const Duration(seconds: 15)))) {
    return;
  }
  NotificationRepository notificationRepository =
      await NotificationRepository.initialize();

  await notificationRepository.scheduleNotification(
      id: notificationId,
      title: 'Parking expiration',
      content:
          message ?? 'Parking at ${parking.parkinglot?.address.toString()}',
      deliveryTime: parking.endTime!.subtract(const Duration(seconds: 15)),
      parkingId: parkingId);
}

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

final List<DarwinNotificationCategory> darwinNotificationCategories =
    <DarwinNotificationCategory>[
  DarwinNotificationCategory(
    iosCategoryIdentifier,
    actions: <DarwinNotificationAction>[
      DarwinNotificationAction.plain(actionId1, 'Extend time by 1 min from now',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          }),
      DarwinNotificationAction.plain(
        actionId2,
        'Extend time by 20 min from now',
        options: <DarwinNotificationActionOption>{
          DarwinNotificationActionOption.foreground,
        },
      ),
      DarwinNotificationAction.plain(actionId3, 'Set a new notification'),
      DarwinNotificationAction.text(
        actionId4,
        'Set notification with message',
        buttonTitle: 'Send',
        placeholder: 'Notification message',
      ),
    ],
    options: <DarwinNotificationCategoryOption>{
      // Show the notification's subtitle, even if the user has disabled notification previews for the app.
      DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
    },
  )
];

Future<FlutterLocalNotificationsPlugin> initializeNotifications() async {
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Android-inställningar
  var initializationSettingsAndroid = const AndroidInitializationSettings(
      '@mipmap/ic_launcher'); // Eller använd egen ikon: '@drawable/ic_notification'

  // iOS-inställningar
  var initializationSettingsIOS = DarwinInitializationSettings(
    notificationCategories: darwinNotificationCategories,
  );

  // Kombinera plattformsinställningar
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: notificationTapBackground,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );
  return flutterLocalNotificationsPlugin;
}

// *************** REPOSITORY ***************

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
      required int id,
      required String parkingId}) async {
    await requestPermissions();

    var iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      categoryIdentifier: iosCategoryIdentifier,
    );
    var platformChannelSpecifics =
        NotificationDetails(iOS: iOSPlatformChannelSpecifics);

    return await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        content,
        payload: parkingId,
        tz.TZDateTime.from(
            deliveryTime,
            tz
                .local), // TZDateTime required to take daylight savings into considerations.
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

// Administrate notification access
  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isMacOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  // Cancel scheduling of notifications
  Future<void> cancelScheduledNotificaion(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
