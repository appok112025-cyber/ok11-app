import 'package:get/get.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/controllers/faq_controller.dart';

class FaqBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FaqController());
  }
}
