import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/site_content.dart';
import 'package:ok11/app/data/repositories/site_content_repository.dart';
import 'package:ok11/app/routes/app_pages.dart';
import 'package:ok11/app/services/firebase_service.dart';
import 'package:ok11/app/widgets/common/app_snackbars.dart';

class FaqController extends GetxController {
  final _repository = SiteContentRepository();
  final _firebaseService = Get.find<FirebaseService>();

  final isLoading = true.obs;
  final faqs = <FAQItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 FaqController.onInit()');
    _firebaseService.setScreenContext(Routes.FAQ);
    Future.microtask(() => loadFAQs());
  }

  Future<void> loadFAQs() async {
    debugPrint('📥 FaqController.loadFAQs()');
    isLoading.value = true;
    try {
      faqs.value = await _repository.getFAQs();
      debugPrint('✅ FaqController.loadFAQs: ${faqs.length} FAQs loaded');
    } catch (e) {
      debugPrint('❌ FaqController.loadFAQs error: $e');
      AppSnackbars.showError('Failed to load FAQs');
      _firebaseService.logError(e, StackTrace.current);
    } finally {
      isLoading.value = false;
    }
  }
}
