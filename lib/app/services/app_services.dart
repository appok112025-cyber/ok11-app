import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppServices extends GetxService {
  final appVersion = 'v2.0.0'.obs;

  Future<AppServices> init() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = 'v${packageInfo.version}';
    } catch (_) {
      appVersion.value = 'v2.0.0';
    }
    return this;
  }
}
