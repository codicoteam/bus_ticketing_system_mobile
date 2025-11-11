import 'package:get/get.dart';
import 'package:busticket/app/modules/auth/controllers/auth_controller.dart';

import '../data/services/auth_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthService(), fenix: true);
    Get.lazyPut(() => AuthController(), fenix: true);
  }
}