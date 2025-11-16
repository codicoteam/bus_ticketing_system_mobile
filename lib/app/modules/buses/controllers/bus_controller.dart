import 'package:get/get.dart';
import '../../../data/models/bus_models.dart';
import '../../../data/services/bus_service.dart';

class BusController extends GetxController {
  final BusService _busService = Get.find<BusService>();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Bus> buses = <Bus>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllBuses();
  }

  Future<void> fetchAllBuses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _busService.getAllBuses();
      
      if (response.success) {
        buses.value = response.buses;
      } else {
        errorMessage.value = response.message;
        buses.clear();
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
      buses.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to convert Bus model to your UI format USING REAL DATA
  Map<String, dynamic> convertBusToUiFormat(Bus bus, String from, String to, DateTime date) {
    return {
      "tripId": bus.id,
      "name": bus.name.isNotEmpty ? bus.name : "${bus.operatorName} ${bus.busNumber}",
      "type": bus.type.isNotEmpty ? bus.type : bus.model,
      "departureTime": _formatTime(bus.departureTime),
      "arrivalTime": _formatTime(bus.arrivalTime),
      "duration": _calculateRealDuration(bus.departureTime, bus.arrivalTime),
      "price": "\$${bus.price != 0.0 ? bus.price.toStringAsFixed(2) : _calculatePriceFromAmenities(bus).toStringAsFixed(2)}", // FIXED: Added toStringAsFixed(2)
      "rating": bus.rating != null ? bus.rating!.toStringAsFixed(1) : _calculateRatingFromFeatures(bus), // FIXED
      "seats": bus.availableSeats != 0 ? bus.availableSeats.toString() : bus.capacity.toString(), // FIXED: Convert to string
      "amenities": bus.amenities, // FIXED - amenities is never null
      "image": bus.imageUrl.isNotEmpty ? bus.imageUrl : _getBusImage(bus.model),
      "originalPrice": bus.originalPrice != null ? "\$${bus.originalPrice!.toStringAsFixed(2)}" : null, // FIXED: Added ! and toStringAsFixed(2)
    };
  }

  String _formatTime(DateTime? time) {
    if (time == null) {
      return _generateFallbackTime();
    }
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _generateFallbackTime() {
    final times = ["06:00 AM", "07:30 AM", "09:00 AM", "11:00 AM", "01:00 PM", "03:00 PM"];
    final index = DateTime.now().millisecond % times.length;
    return times[index];
  }

  String _calculateRealDuration(DateTime? departure, DateTime? arrival) {
    if (departure == null || arrival == null) {
      return _generateFallbackDuration();
    }
    
    final difference = arrival.difference(departure);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    
    return '${hours}h ${minutes}m';
  }

  String _generateFallbackDuration() {
    final durations = ["5h 30m", "6h 0m", "6h 30m", "7h 0m"];
    final index = DateTime.now().millisecond % durations.length;
    return durations[index];
  }

  double _calculatePriceFromAmenities(Bus bus) { // FIXED: Changed return type to double
    double basePrice = 15.0; // FIXED: Changed to double
    final amenities = bus.amenities;
    
    if (amenities.contains("AC") || amenities.contains("Air Conditioning")) basePrice += 10;
    if (amenities.contains("WiFi") || amenities.contains("Wi-Fi")) basePrice += 5;
    if (amenities.contains("Charging Ports") || amenities.contains("Charging")) basePrice += 5;
    if (bus.model.toLowerCase().contains("volvo")) basePrice += 10;
    if (amenities.contains("TV") || amenities.contains("Entertainment")) basePrice += 8;
    if (amenities.contains("Toilet")) basePrice += 7;
    
    return basePrice;
  }

  String _calculateRatingFromFeatures(Bus bus) {
    double rating = 4.0;
    final amenities = bus.amenities;
    
    if (amenities.length > 2) rating += 0.3;
    if (bus.model.toLowerCase().contains("volvo")) rating += 0.4;
    if (bus.capacity > 40) rating += 0.2;
    if (amenities.contains("AC")) rating += 0.2;
    if (amenities.contains("WiFi")) rating += 0.1;
    
    rating = rating.clamp(3.5, 5.0);
    return rating.toStringAsFixed(1);
  }

  String _getBusImage(String model) {
    if (model.toLowerCase().contains("volvo")) {
      return "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400";
    } else {
      return "https://images.unsplash.com/photo-1570125909232-eb263c188f7e?w=400";
    }
  }

  List<Bus> searchBusesByRoute(String from, String to) {
    return buses.where((bus) {
      final originMatch = bus.origin.toLowerCase().contains(from.toLowerCase());
      final destinationMatch = bus.destination.toLowerCase().contains(to.toLowerCase());
      return originMatch && destinationMatch;
    }).toList();
  }

  List<Bus> getAvailableBuses(String from, String to, DateTime date) {
    return buses.where((bus) {
      final routeMatch = bus.origin.toLowerCase().contains(from.toLowerCase()) &&
                        bus.destination.toLowerCase().contains(to.toLowerCase());
      final dateMatch = true;
      final isActive = bus.isActive;
      final hasAvailableSeats = bus.actualAvailableSeats > 0;
      
      return routeMatch && dateMatch && isActive && hasAvailableSeats;
    }).toList();
  }

  // Get bus by ID
  Bus? getBusById(String busId) {
    try {
      return buses.firstWhere((bus) => bus.id == busId);
    } catch (e) {
      return null;
    }
  }

  // Get buses by operator
  List<Bus> getBusesByOperator(String operatorName) {
    return buses.where((bus) => bus.operatorName.toLowerCase().contains(operatorName.toLowerCase())).toList();
  }

  // Get active buses only
  List<Bus> get activeBuses {
    return buses.where((bus) => bus.isActive).toList();
  }

  // Get buses with specific amenity
  List<Bus> getBusesWithAmenity(String amenity) {
    return buses.where((bus) => bus.hasAmenity(amenity)).toList();
  }
}