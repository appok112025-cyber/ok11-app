import 'package:get/get.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/controllers/about_controller.dart';

class AboutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AboutController());
  }
}
