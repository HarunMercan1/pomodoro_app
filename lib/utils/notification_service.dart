import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Singleton yapısı (Her yerden tek bir instance'a ulaşmak için)
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Android ayarları (ikon adı drawable klasöründe olmalı, varsayılan ikon 'icon' ise belirtiyoruz)
    // Eğer uygulamanın ikonu 'mipmap/ic_launcher' ise buraya '@mipmap/ic_launcher' yazılabilir
    // Ama flutter_local_notifications genelde drawable/app_icon arar.
    // Şimdilik varsayılan android ikonunu kullanalım.
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS ayarları
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    // Android 13+ için bildirim izni isteyelim
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pomodoro_channel_id', // Kanal ID'si
      'Pomodoro Timer', // Kanal Adı
      channelDescription: 'Pomodoro zamanlayıcı bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true, // TİTREŞİM BURADA AÇILIYOR
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0, // Bildirim ID'si (Hep aynısını kullanırsak üstüne yazar, kirlilik olmaz)
      title,
      body,
      details,
    );
  }
}