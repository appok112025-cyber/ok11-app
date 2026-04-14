import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final currentIndex = 0.obs;

  void onTabTapped(int index) {
    debugPrint('🔄 DashboardController.onTabTapped: $index');
    currentIndex.value = index;
  }
}
