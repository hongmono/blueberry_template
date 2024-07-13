import 'package:blueberry_flutter_template/modules/core/notification/local_notification_manager.dart';
import 'package:blueberry_flutter_template/modules/core/storage/FlutterSecureStorage.dart';
import 'package:blueberry_flutter_template/modules/core/storage/StorageKeys.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FirebaseCloudMessagingManager {
  static Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    try {
      String? token;

      if (kIsWeb) {
        token = await FirebaseMessaging.instance.getToken(
          vapidKey:
              'BEQthYLUnGpCx7bT4Pvukld8RCQemi6TKhTN6J0I4pjuTkY4QQ-PqkYenhizmvsYbM53RibV6OBYOtdx8M6GrWo',
        );
      } else {
        token = await FirebaseMessaging.instance.getToken();
      }

      if (token == null) {
        throw Exception('Failed to get FCM token');
      }

      debugPrint('FCM Token: $token');

      final storage = PreferenceStorage();
      storage.write(StorageKeys.fcmToken, token);
    } catch (e) {
      debugPrint('Failed initialize FCM]] $e');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      // TODO: If necessary send token to application server.
    }).onError((err) {
      // Error getting token.
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // await LocalNotificationManager.initialize();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification == null) return;

      // LocalNotificationManager.showNotification({
      //   'title': message.notification!.title,
      //   'body': message.notification!.body,
      // });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification == null) return;

      print('A new onMessageOpenedApp event was published! ${message.data}');

      // LocalNotificationManager.showNotification({
      //   'title': message.notification!.title,
      //   'body': message.notification!.body,
      // });
    });
  }

  static Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  static Future<void> deleteToken() async {
    await FirebaseMessaging.instance.deleteToken();
  }

  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}
