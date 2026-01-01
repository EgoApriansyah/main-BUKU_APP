import 'dart:io'; // Tambahkan import ini
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);

    // MINTA IZIN OTOMATIS SAAT APP DIBUKA
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        // Ini akan memunculkan dialog "Allow Buku App to send notifications?"
        await androidImplementation.requestNotificationsPermission();
      }
    }
  }

  static Future<void> showNotification(String title, String body) async {
    // Gunakan ID unik agar notifikasi tidak saling menimpa
    int notificationId = DateTime.now().millisecond;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'buku_app_channel',
      'Buku App Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}