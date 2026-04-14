import 'package:get/get.dart';
import 'package:ok11/app/modules/dashboard/pages/match_detail/controllers/match_detail_controller.dart';

class MatchDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatchDetailController>(
      () => MatchDetailController(),
      fenix: true,
    );
  }
}
