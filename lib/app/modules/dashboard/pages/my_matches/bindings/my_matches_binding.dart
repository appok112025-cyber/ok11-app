import 'package:get/get.dart';
import 'package:ok11/app/modules/dashboard/pages/my_matches/controllers/my_matches_controller.dart';

class MyMatchesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyMatchesController>(() => MyMatchesController());
  }
}
