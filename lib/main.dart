import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:ok11/app/routes/app_pages.dart';
import 'package:ok11/app/theme/app_theme.dart';
import 'package:ok11/firebase_options.dart';
import 'package:ok11/app/services/app_services.dart';
import 'package:ok11/app/services/firebase_service.dart';
import 'package:ok11/app/services/api_service.dart';
import 'package:ok11/app/services/submission_service.dart';
import 'package:ok11/app/stores/auth_store.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top],
      );

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (kReleaseMode) {
        FlutterError.onError = (FlutterErrorDetails details) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        };

        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      } else {
        FlutterError.onError = (FlutterErrorDetails details) {
          debugPrint('Error FlutterError: ${details.exception}');
          debugPrint('Stack trace: ${details.stack}');
          FlutterError.presentError(details);
        };

        PlatformDispatcher.instance.onError = (error, stack) {
          debugPrint('Error PlatformDispatcher: $error');
          debugPrint('Stack trace: $stack');
          return true;
        };
      }

      await Get.putAsync<AppServices>(
        () async => AppServices().init(),
        permanent: true,
      );

      await Get.putAsync<FirebaseService>(
        () async => FirebaseService().init(),
        permanent: true,
      );

      Get.put<ApiService>(ApiService(), permanent: true);
      Get.put<AuthStore>(AuthStore(), permanent: true);

      await Get.putAsync<SubmissionService>(
        () async => SubmissionService().init(),
        permanent: true,
      );

      runApp(const MyApp());
    },
    (error, stack) {
      debugPrint('Error Main: $error');
      debugPrint('Stack trace: $stack');
      if (kReleaseMode) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "OK11",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: AppTheme.theme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      smartManagement: SmartManagement.full,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}
