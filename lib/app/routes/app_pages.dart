import 'package:get/get.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/modules/auth/login/bindings/login_binding.dart';
import 'package:ok11/app/modules/auth/login/views/login_view.dart';
import 'package:ok11/app/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:ok11/app/modules/dashboard/pages/home/bindings/home_binding.dart';
import 'package:ok11/app/modules/dashboard/pages/home/views/home_view.dart';
import 'package:ok11/app/modules/dashboard/pages/match_detail/bindings/match_detail_binding.dart';
import 'package:ok11/app/modules/dashboard/pages/match_detail/views/match_detail_view.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/bindings/about_binding.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/bindings/faq_binding.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/bindings/points_binding.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/bindings/profile_binding.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/bindings/terms_binding.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/bindings/update_profile_binding.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/views/about_view.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/views/faq_view.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/views/points_view.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/views/profile_view.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/views/terms_view.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/views/update_profile_view.dart';
import 'package:ok11/app/modules/dashboard/views/dashboard_view.dart';

import 'package:ok11/app/modules/utils/splash/bindings/splash_binding.dart';
import 'package:ok11/app/modules/utils/splash/views/splash_view.dart';
import 'package:ok11/app/modules/auth/blocked/views/blocked_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // ignore: constant_identifier_names
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.UPDATE_PROFILE,
      page: () => const UpdateProfileView(),
      binding: UpdateProfileBinding(),
    ),
    GetPage(
      name: _Paths.TERMS,
      page: () => const TermsView(),
      binding: TermsBinding(),
    ),
    GetPage(
      name: _Paths.POINTS,
      page: () => const PointsView(),
      binding: PointsBinding(),
    ),
    GetPage(
      name: _Paths.ABOUT,
      page: () => const AboutView(),
      binding: AboutBinding(),
    ),
    GetPage(
      name: _Paths.FAQ,
      page: () => const FaqView(),
      binding: FaqBinding(),
    ),
    GetPage(
      name: _Paths.MATCH_DETAIL,
      page: () {
        final arguments = Get.arguments;
        if (arguments is MatchData) {
          return MatchDetailView(matchData: arguments);
        } else if (arguments is String) {
          return MatchDetailView(teams: arguments);
        } else {
          return const MatchDetailView(teams: 'Match');
        }
      },
      binding: MatchDetailBinding(),
    ),
    GetPage(name: _Paths.BLOCKED, page: () => const BlockedView()),
  ];
}
