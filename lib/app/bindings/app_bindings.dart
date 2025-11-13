import 'package:get/get.dart';
import 'package:busticket/app/modules/auth/controllers/auth_controller.dart';
import 'package:busticket/app/modules/booking/controllers/booking_controller.dart';

import '../data/services/auth_service.dart';
import '../data/services/booking_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut(() => AuthService(), fenix: true);
    Get.lazyPut(() => BookingService(), fenix: true); // Add this line
    
    // Controllers
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => BookingController(), fenix: true); // Add this line
  }
}