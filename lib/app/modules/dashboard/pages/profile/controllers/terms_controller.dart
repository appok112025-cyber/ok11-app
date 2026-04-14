import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/site_content.dart';
import 'package:ok11/app/data/repositories/site_content_repository.dart';
import 'package:ok11/app/routes/app_pages.dart';
import 'package:ok11/app/services/firebase_service.dart';
import 'package:ok11/app/widgets/common/app_snackbars.dart';

class TermsController extends GetxController {
  final _repository = SiteContentRepository();
  final _firebaseService = Get.find<FirebaseService>();

  final isLoading = true.obs;
  final termsContent = Rxn<TermsContent>();

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 TermsController.onInit()');
    _firebaseService.setScreenContext(Routes.TERMS);
    Future.microtask(() => loadContent());
  }

  Future<void> loadContent() async {
    debugPrint('📥 TermsController.loadContent()');
    isLoading.value = true;
    try {
      termsContent.value = await _repository.getTermsContent();
      debugPrint('✅ TermsController.loadContent: Success');
    } catch (e) {
      debugPrint('❌ TermsController.loadContent error: $e');
      AppSnackbars.showError('Failed to load content');
      _firebaseService.logError(e, StackTrace.current);
    } finally {
      isLoading.value = false;
    }
  }
}
