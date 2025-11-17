import 'package:get/get.dart';
import '../../../data/models/busroute_models.dart';
import '../../../data/services/route_service.dart';

class RouteController extends GetxController {
  final RouteService _routeService = Get.find<RouteService>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<BusRoute> routes = <BusRoute>[].obs;
  final RxBool _hasLoaded = false.obs; // Add this flag

  @override
  void onInit() {
    super.onInit();
    // Load routes when controller initializes, not in widget initState
    fetchAllRoutes();
  }

  Future<void> fetchAllRoutes() async {
    try {
      // Prevent multiple simultaneous calls
      if (isLoading.value) return;

      isLoading.value = true;
      errorMessage.value = '';

      final response = await _routeService.getAllRoutes();

      if (response.success) {
        routes.value = response.routes;
        _hasLoaded.value = true; // Mark as loaded
      } else {
        errorMessage.value = response.message;
        routes.clear();
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
      routes.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Get exactly 3 popular routes for home screen
  List<BusRoute> get popularRoutes {
    // If we have less than 3 routes, return what we have
    // If we have more than 3, return first 3
    return routes.take(3).toList();
  }

  // Check if we have data loaded
  bool get hasData => routes.isNotEmpty && _hasLoaded.value;

  // Search routes by origin and destination
  List<BusRoute> searchRoutes(String from, String to) {
    return routes.where((route) {
      final originMatch = route.origin.toLowerCase().contains(
        from.toLowerCase(),
      );
      final destinationMatch = route.destination.toLowerCase().contains(
        to.toLowerCase(),
      );
      return originMatch && destinationMatch;
    }).toList();
  }
}
