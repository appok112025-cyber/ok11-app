import 'package:get/get.dart';
import 'package:ok11/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:ok11/app/modules/dashboard/pages/home/controllers/home_controller.dart';
import 'package:ok11/app/modules/dashboard/pages/my_matches/controllers/my_matches_controller.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/controllers/profile_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<MyMatchesController>(() => MyMatchesController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
