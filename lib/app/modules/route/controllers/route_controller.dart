// lib/app/modules/route/controllers/route_controller.dart
import 'package:get/get.dart';
import '../../../data/models/busroute_models.dart';
import '../../../data/services/route_service.dart';

class RouteController extends GetxController {
  final RouteService _routeService = Get.find<RouteService>();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<BusRoute> routes = <BusRoute>[].obs; // Use BusRoute here

  Future<void> fetchAllRoutes() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _routeService.getAllRoutes();
      
      if (response.success) {
        routes.value = response.routes;
      } else {
        errorMessage.value = response.message;
        routes.clear();
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
      routes.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Get popular routes (you can customize this logic)
  List<BusRoute> get popularRoutes { // Use BusRoute here
    return routes.take(6).toList(); // Show first 6 routes as popular
  }

  // Search routes by origin and destination
  List<BusRoute> searchRoutes(String from, String to) { // Use BusRoute here
    return routes.where((route) {
      final originMatch = route.origin.toLowerCase().contains(from.toLowerCase());
      final destinationMatch = route.destination.toLowerCase().contains(to.toLowerCase());
      return originMatch && destinationMatch;
    }).toList();
  }
}