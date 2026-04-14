import 'package:get/get.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/controllers/points_controller.dart';

class PointsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PointsController());
  }
}
