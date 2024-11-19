import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitness_workout_app/main.dart';
import 'package:fitness_workout_app/view/home/notification_view.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationServices {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _androidChannel = const AndroidNotificationChannel(
    'workout_channel',
    'Workout Notifications',
    description: 'This channel is used for workout reminders',
    importance: Importance.max,
  );

  NotificationServices() {
    // Khởi tạo múi giờ
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  }

  Future<void> initNotifications() async {
    // Yêu cầu quyền từ người dùng
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('User declined or has not accepted permission');
      return;
    }

    List<PendingNotificationRequest> pendingNotifications = await _localNotifications.pendingNotificationRequests();
    for (var notification in pendingNotifications) {
      print('ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
    }

    await initLocalNotifications();
  }

  Future<void> initLocalNotifications() async {
    const DarwinInitializationSettings iOS = DarwinInitializationSettings();
    const AndroidInitializationSettings android = AndroidInitializationSettings('@drawable/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        final payload = notificationResponse.payload;
        if (payload != null) {
          final message = RemoteMessage.fromMap(jsonDecode(payload));
          handleMessage(message);
        }
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed(
      NotificationView.route,
      arguments: message,
    );
  }

  Future<String> scheduleWorkoutNotification({
    required String id,
    required DateTime scheduledTime,
    required String workoutName,
    required String repeatInterval,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'workout_channel',
      'Workout Notifications',
      channelDescription: 'This channel is used for workout reminders',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'icon_app',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );
    DateTime newScheduledTime = scheduledTime;

    // Nếu lặp lại là 'Everyday', kiểm tra xem thời gian đã qua chưa
    if (repeatInterval == 'Everyday') {
      if (newScheduledTime.isBefore(DateTime.now())) {
        newScheduledTime = newScheduledTime.add(Duration(days: 1)); // Nếu thời gian đã qua, chuyển sang ngày hôm sau
      }
    }
    // Nếu lặp lại là các ngày trong tuần (Monday, Friday)
    else if (repeatInterval.contains(',')) {
      newScheduledTime = _getNextWeekdayWithSameTime(DateTime.now(), repeatInterval, scheduledTime);
    }

    final tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(newScheduledTime, tz.local);

    //print('Scheduled Time: $scheduledTZDateTime');

    if (repeatInterval == 'no') {
      // Thông báo một lần
      await _localNotifications.zonedSchedule(
        id.hashCode,
        'Workout Reminder',
        'It\'s time for your workout: $workoutName',
        scheduledTZDateTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      );
    } else if (repeatInterval == 'Everyday') {
      // Thông báo hàng ngày
      await _localNotifications.zonedSchedule(
        id.hashCode,
        'Daily Workout Reminder',
        'It\'s time for your daily workout: $workoutName',
        scheduledTZDateTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else {
      // Tính toán ngày kết thúc (30 ngày sau)
      final DateTime endDate = scheduledTime.add(Duration(days: 30));
      final tz.TZDateTime endTZDateTime = tz.TZDateTime.from(endDate, tz.local);
      //print('End Date: $endTZDateTime');

      // Chia danh sách các ngày lặp lại
      List<String> daysOfWeek = repeatInterval.split(',');
      //print('Parsed days of week: $daysOfWeek');
      Set<int> weekdaysSet = {};

      for (String day in daysOfWeek) {
        final int weekday = _getWeekdayFromString(day.trim());
        if (weekday != -1) {
          weekdaysSet.add(weekday);
        }
      }

      // Duyệt qua các ngày trong tuần và lên lịch thông báo
      tz.TZDateTime currentScheduledTime = scheduledTZDateTime;

      while (currentScheduledTime.isBefore(endTZDateTime)) {
        if (weekdaysSet.contains(currentScheduledTime.weekday)) {
          // Nếu ngày trong tuần nằm trong danh sách, lên lịch thông báo
          await _localNotifications.zonedSchedule(
            id.hashCode,
            'Weekly Workout Reminder',
            'It\'s time for your workout: $workoutName',
            currentScheduledTime,
            platformDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
            matchDateTimeComponents: DateTimeComponents.time,
          );
          //print('Scheduled ${id.hashCode} notification for: $currentScheduledTime');
        }

        // Tính ngày tiếp theo trong tuần
        currentScheduledTime = _nextInstanceOfWeekday(currentScheduledTime, weekdaysSet);
      }

      // Kiểm tra nếu ngày lên lịch không nằm trong danh sách, thêm vào
      if (!weekdaysSet.contains(scheduledTZDateTime.weekday)) {
        // Lên lịch thông báo cho ngày lên lịch ban đầu
        await _localNotifications.zonedSchedule(
          id.hashCode,
          'Workout Reminder',
          'It\'s time for your workout: $workoutName',
          scheduledTZDateTime,
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        //print('Scheduled notification ${id.hashCode} for the initial day: $scheduledTZDateTime');
      }
    }
    return id.hashCode.toString();
  }

  DateTime _getNextWeekdayWithSameTime(DateTime currentDateTime, String repeatInterval, DateTime originalScheduledTime) {
    // Chuyển đổi các ngày trong tuần từ chuỗi 'Monday,Friday' thành danh sách các ngày trong tuần
    List<String> daysOfWeek = repeatInterval.split(',');
    List<int> weekdaysSet = [];

    for (String day in daysOfWeek) {
      final int weekday = _getWeekdayFromString(day.trim());
      if (weekday != -1) {
        weekdaysSet.add(weekday);
      }
    }

    // Lưu giờ ban đầu để giữ nguyên
    DateTime newScheduledTime = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day,
        originalScheduledTime.hour, originalScheduledTime.minute);

    // Tìm ngày gần nhất trong tuần cho mỗi ngày yêu cầu
    while (!weekdaysSet.contains(newScheduledTime.weekday)) {
      newScheduledTime = newScheduledTime.add(Duration(days: 1)); // Tìm ngày tiếp theo trong tuần
    }

    // Kiểm tra xem thời gian có qua chưa, nếu có, chuyển sang ngày tiếp theo
    if (newScheduledTime.isBefore(currentDateTime)) {
      newScheduledTime = newScheduledTime.add(Duration(days: 7)); // Nếu đã qua, chuyển sang tuần sau
    }

    return newScheduledTime;
  }

  int _getWeekdayFromString(String day) {
    switch (day.toLowerCase()) {
      case 'monday': return DateTime.monday;
      case 'tuesday': return DateTime.tuesday;
      case 'wednesday': return DateTime.wednesday;
      case 'thursday': return DateTime.thursday;
      case 'friday': return DateTime.friday;
      case 'saturday': return DateTime.saturday;
      case 'sunday': return DateTime.sunday;
      default: return -1;
    }
  }

// Cập nhật để tránh lặp vô hạn và chỉ lấy các ngày trong tuần cần thông báo
  tz.TZDateTime _nextInstanceOfWeekday(tz.TZDateTime dateTime, Set<int> weekdaysSet) {
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    do {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    } while (!weekdaysSet.contains(scheduledDate.weekday));

    return scheduledDate;
  }

}
