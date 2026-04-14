import 'dart:convert';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:ok11/firebase_options.dart';
import 'package:ok11/app/routes/app_pages.dart';
import 'package:ok11/app/stores/auth_store.dart';

// Callback type for notification-triggered refresh
typedef NotificationRefreshCallback =
    void Function(String type, Map<String, dynamic> data);

class FirebaseService extends GetxService {
  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
  static FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Callback for in-app refresh when notification is received
  NotificationRefreshCallback? onNotificationReceived;

  Future<FirebaseService> init() async {
    await _initAnalytics();
    await _initCrashlytics();
    await _initMessaging();
    // Subscribe to general topic for admin notifications
    await subscribeToTopic('general');
    return this;
  }

  Future<void> _initAnalytics() async {
    await analytics.setAnalyticsCollectionEnabled(true);
    if (kDebugMode) {
      debugPrint('Firebase Analytics initialized');
    }
  }

  Future<void> _initCrashlytics() async {
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    if (kDebugMode) {
      debugPrint('Firebase Crashlytics initialized');
    }
  }

  Future<void> _initMessaging() async {
    try {
      await _initializeLocalNotifications();
      await _requestPermissions();
      await _setupFirebaseMessaging();
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Error initializing messaging: $e');
        debugPrint('Stack trace: $stack');
      }
      await logError(e, stack);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'ok11_notifications',
      'OK11 Notifications',
      description: 'Notifications for match updates and scores',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      final areEnabled = await androidImplementation?.areNotificationsEnabled();
      if (areEnabled == true) {
        if (kDebugMode) {
          debugPrint('Android notifications already enabled');
        }
        await logEvent('notification_permission_granted', {});
      } else {
        final granted = await androidImplementation
            ?.requestNotificationsPermission();
        if (granted == true) {
          if (kDebugMode) {
            debugPrint('Android notification permission granted');
          }
          await logEvent('notification_permission_granted', {});
        } else {
          if (kDebugMode) {
            debugPrint('Android notification permission denied');
          }
          await logEvent('notification_permission_denied', {});
        }
      }
    } else if (Platform.isIOS) {
      final iosImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      final granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (granted == true) {
        if (kDebugMode) {
          debugPrint('iOS notification permission granted');
        }
        await logEvent('notification_permission_granted', {});
      } else {
        if (kDebugMode) {
          debugPrint('iOS notification permission denied');
        }
        await logEvent('notification_permission_denied', {});
      }
    }

    final fcmPermission = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint('FCM permission status: ${fcmPermission.authorizationStatus}');
    }
  }

  Future<void> _setupFirebaseMessaging() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('📩 Foreground message received: ${message.messageId}');
        debugPrint('📩 Message data: ${message.data}');
        debugPrint('📩 Has notification: ${message.notification != null}');
      }

      // Handle data-only messages (silent updates)
      _handleDataMessage(message.data);

      // Show notification if it has a notification payload
      if (message.notification != null) {
        _showNotification(message);
      }

      // Trigger in-app refresh callback
      _triggerRefreshCallback(message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    final token = await messaging.getToken();
    if (kDebugMode && token != null) {
      debugPrint('FCM Token: $token');
    }

    messaging.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) {
        debugPrint('FCM Token refreshed: $newToken');
      }
      logEvent('fcm_token_refreshed', {'token': newToken});

      try {
        if (Get.isRegistered<AuthStore>()) {
          final authStore = Get.find<AuthStore>();
          if (authStore.isAuthenticated.value) {
            await authStore.updateFcmToken(newToken);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error updating FCM token on refresh: $e');
        }
        logError(e, StackTrace.current);
      }
    });
  }

  /// Handle data-only messages for silent updates
  void _handleDataMessage(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    final type = data['type'] as String?;
    if (kDebugMode) {
      debugPrint('📊 Data message type: $type');
    }

    switch (type) {
      case 'match_updated':
        if (kDebugMode) {
          debugPrint('🔄 Match updated notification received');
          debugPrint('   matchId: ${data['matchId']}');
          debugPrint('   status: ${data['status']}');
        }
        // The refresh callback will handle the actual refresh
        break;
      case 'match_live':
      case 'match_completed':
      case 'match_cancelled':
        if (kDebugMode) {
          debugPrint('🏏 Match status change: $type');
        }
        break;
      default:
        if (kDebugMode) {
          debugPrint('📨 Unknown data message type: $type');
        }
    }
  }

  void _triggerRefreshCallback(Map<String, dynamic> data) {
    if (onNotificationReceived != null) {
      final type = data['type'] as String? ?? 'unknown';
      if (kDebugMode) {
        debugPrint('Triggering notification refresh callback: $type');
      }
      onNotificationReceived!(type, data);
    }
  }

  Future<bool> _checkNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final areEnabled = await androidImplementation?.areNotificationsEnabled();
      return areEnabled ?? false;
    } else if (Platform.isIOS) {
      final iosImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final result = await iosImplementation?.checkPermissions();
      return result?.isEnabled ?? false;
    }
    return true;
  }

  void _onNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('Notification tapped: ${response.payload}');
    }

    try {
      if (response.payload != null) {
        final decoded = jsonDecode(response.payload!);
        final data = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (data != null) {
          _handleNotificationData(data);
        }
      }

      logEvent('notification_tapped', {
        'notification_id': response.id?.toString() ?? '',
        'action': response.actionId ?? 'tap',
        'payload': response.payload ?? '',
      });
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Error parsing notification payload: $e');
        debugPrint('Stack trace: $stack');
      }
      logError(e, stack);
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final hasPermission = await _checkNotificationPermission();
    if (!hasPermission) {
      if (kDebugMode) {
        debugPrint(
          'Notification permission not granted, skipping notification',
        );
      }
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'ok11_notifications',
      'OK11 Notifications',
      channelDescription: 'Notifications for match updates and scores',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        details,
        payload: jsonEncode(message.data),
      );

      await logEvent('notification_received', {
        'title': notification.title ?? '',
        'body': notification.body ?? '',
      });
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Error showing notification: $e');
        debugPrint('Stack trace: $stack');
      }
      await logError(e, stack);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    _handleNotificationData(message.data);
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    if (kDebugMode) {
      debugPrint('Notification data: $data');
    }

    final notificationType = data['type'] as String?;

    if (notificationType == 'user_blocked' ||
        notificationType == 'user_unblocked') {
      logEvent('notification_opened', {'type': notificationType ?? 'unknown'});
      return;
    }

    final analyticsData = <String, Object>{
      'has_route': (data['route'] != null).toString(),
      'has_match_id': (data['match_id'] != null).toString(),
      'has_teams': (data['teams'] != null).toString(),
    };
    logEvent('notification_opened', analyticsData);

    final route = data['route'] as String?;
    final matchId = data['match_id'] as String?;
    final teams = data['teams'] as String?;

    if (route != null) {
      _navigateToRoute(route, matchId: matchId, teams: teams);
    } else if (matchId != null || teams != null) {
      _navigateToMatchDetail(teams: teams ?? 'Match');
    }
  }

  void _navigateToRoute(String route, {String? matchId, String? teams}) {
    try {
      switch (route) {
        case Routes.MATCH_DETAIL:
          _navigateToMatchDetail(teams: teams);
          break;
        case Routes.DASHBOARD:
        case Routes.HOME:
          Get.offAllNamed(Routes.DASHBOARD);
          break;
        default:
          if (kDebugMode) {
            debugPrint('Unknown route: $route');
          }
      }
    } catch (e) {
      _handleNavigationError(e);
    }
  }

  void _navigateToMatchDetail({String? teams}) {
    try {
      Get.toNamed(Routes.MATCH_DETAIL, arguments: teams ?? 'Match');
    } catch (e) {
      _handleNavigationError(e);
    }
  }

  void _handleNavigationError(dynamic error) {
    if (kDebugMode) {
      debugPrint('Navigation error: $error');
    }
    logError(error, StackTrace.current);
  }

  Future<String?> getFcmToken() async {
    return await messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        debugPrint('Subscribed to topic: $topic');
      }
      logEvent('fcm_topic_subscribed', {'topic': topic});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error subscribing to topic $topic: $e');
      }
      logError(e, StackTrace.current);
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        debugPrint('Unsubscribed from topic: $topic');
      }
      logEvent('fcm_topic_unsubscribed', {'topic': topic});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error unsubscribing from topic $topic: $e');
      }
      logError(e, StackTrace.current);
    }
  }

  Future<void> subscribeToMatch(String matchId) async {
    await subscribeToTopic('match_$matchId');
  }

  Future<void> unsubscribeFromMatch(String matchId) async {
    await unsubscribeFromTopic('match_$matchId');
  }

  Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    try {
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error logging event $name: $e');
      }
    }
  }

  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    bool fatal = false,
  }) async {
    await crashlytics.recordError(error, stackTrace, fatal: fatal);
  }

  // Enhanced Flutter 3.38+ features
  void setUserContext({
    required String userId,
    String? email,
    String? userName,
  }) {
    crashlytics.setUserIdentifier(userId);
    crashlytics.setCustomKey('user_id', userId);
    if (email != null) {
      crashlytics.setCustomKey('email', email);
    }
    if (userName != null) {
      crashlytics.setCustomKey('user_name', userName);
    }
    analytics.setUserId(id: userId);
  }

  void setScreenContext(String screenName) {
    crashlytics.setCustomKey('current_screen', screenName);
    analytics.logScreenView(screenName: screenName);
  }

  void logBreadcrumb(String message, {Map<String, dynamic>? data}) {
    crashlytics.log(message);
    if (data != null) {
      data.forEach((key, value) {
        crashlytics.setCustomKey(key, value.toString());
      });
    }
  }

  // Enhanced analytics with engagement tracking
  Future<void> logUserEngagement({
    required int engagementTimeMs,
    String? sessionId,
  }) async {
    await analytics.logEvent(
      name: 'user_engagement',
      parameters: {
        'engagement_time_msec': engagementTimeMs,
        if (sessionId != null) 'session_id': sessionId,
      },
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    debugPrint('Background message: ${message.messageId}');
    debugPrint('Background message data: ${message.data}');
  }
}
