import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/site_content.dart';
import 'package:ok11/app/data/repositories/site_content_repository.dart';
import 'package:ok11/app/routes/app_pages.dart';
import 'package:ok11/app/services/firebase_service.dart';
import 'package:ok11/app/widgets/common/app_snackbars.dart';

class PointsController extends GetxController {
  final _repository = SiteContentRepository();
  final _firebaseService = Get.find<FirebaseService>();

  final isLoading = true.obs;
  final pointsContent = Rxn<PointsContent>();
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 PointsController.onInit()');
    _firebaseService.setScreenContext(Routes.POINTS);
    Future.microtask(() => loadContent());
  }

  Future<void> loadContent() async {
    debugPrint('📥 PointsController.loadContent()');
    isLoading.value = true;
    try {
      pointsContent.value = await _repository.getPointsContent();
      debugPrint('✅ PointsController.loadContent: Success');
    } catch (e) {
      debugPrint('❌ PointsController.loadContent error: $e');
      AppSnackbars.showError('Failed to load content');
      _firebaseService.logError(e, StackTrace.current);
    } finally {
      isLoading.value = false;
    }
  }
}
