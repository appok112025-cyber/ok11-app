import 'package:get/get.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/controllers/terms_controller.dart';

class TermsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TermsController());
  }
}
