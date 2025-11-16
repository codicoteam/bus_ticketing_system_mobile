import 'package:get/get.dart';
import 'package:busticket/app/modules/auth/controllers/auth_controller.dart';
import 'package:busticket/app/modules/booking/controllers/booking_controller.dart';
import '../data/services/auth_service.dart';
import '../data/services/booking_service.dart';
import '../data/services/bus_service.dart';
import '../data/services/notification_service.dart';
import '../data/services/payment_service.dart';
import '../data/services/route_service.dart';
import '../data/services/ticket_service.dart';
import '../data/services/trip_service.dart'; // ADD THIS IMPORT
import '../modules/buses/controllers/bus_controller.dart';
import '../modules/notifications/controllers/notification_controller.dart';
import '../modules/payments/controllers/payment_controller.dart';
import '../modules/profile/controllers/profile_controller.dart';
import '../modules/route/controllers/route_controller.dart';
import '../modules/tickets/controllers/ticket_controller.dart';
import '../modules/trips/controllers/trip_controller.dart'; // ADD THIS IMPORT

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut(() => AuthService(), fenix: true);
    Get.lazyPut(() => BookingService(), fenix: true);
    Get.lazyPut(() => BusService(), fenix: true);
    Get.lazyPut(() => RouteService(), fenix: true);
    Get.lazyPut(() => TripService(), fenix: true);
    Get.lazyPut(() => PaymentService(), fenix: true);
    Get.lazyPut(() => TicketService());
    Get.lazyPut(() => NotificationService());

    // Controllers
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => BookingController(), fenix: true);
    Get.lazyPut(() => BusController(), fenix: true);
    Get.lazyPut(() => RouteController(), fenix: true);
    Get.lazyPut(() => TripController(), fenix: true);
    Get.lazyPut(() => PaymentController(), fenix: true);
    Get.lazyPut(() => TicketController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => NotificationController());
  }
}
