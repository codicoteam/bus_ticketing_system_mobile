// lib/app/controllers/trip_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/trip_models.dart';
import '../../../data/services/trip_service.dart';

class TripController extends GetxController {
  final TripService _tripService = Get.find<TripService>();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Trip> trips = <Trip>[].obs;
  final RxList<Trip> filteredTrips = <Trip>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllTrips();
  }

  Future<void> fetchAllTrips() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _tripService.getAllTrips();
      
      if (response.success) {
        trips.value = response.trips;
        filteredTrips.value = response.trips;
      } else {
        errorMessage.value = response.message;
        trips.clear();
        filteredTrips.clear();
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
      trips.clear();
      filteredTrips.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Add this method to show all trips
  void showAllTrips() {
    filteredTrips.value = trips;
    errorMessage.value = '';
  }

  // UPDATED searchTrips method to handle empty search
  Future<void> searchTrips(String from, String to) async {
    // If both are empty, show all trips
    if (from.isEmpty && to.isEmpty) {
      showAllTrips();
      return;
    }
    
    // If only one field is filled, show error
    if (from.isEmpty || to.isEmpty) {
      errorMessage.value = 'Please enter both origin and destination';
      filteredTrips.clear();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _tripService.getTripsByRoute(from, to);
      
      if (response.success) {
        filteredTrips.value = response.trips;
      } else {
        errorMessage.value = response.message;
        filteredTrips.clear();
      }
    } catch (e) {
      errorMessage.value = 'Search failed. Please try again.';
      filteredTrips.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void filterByTime(String timeFilter) {
    switch (timeFilter) {
      case 'morning':
        filteredTrips.value = trips.where((trip) => 
          trip.departureTime.hour >= 6 && trip.departureTime.hour < 12
        ).toList();
        break;
      case 'afternoon':
        filteredTrips.value = trips.where((trip) => 
          trip.departureTime.hour >= 12 && trip.departureTime.hour < 18
        ).toList();
        break;
      case 'evening':
        filteredTrips.value = trips.where((trip) => 
          trip.departureTime.hour >= 18
        ).toList();
        break;
      default:
        filteredTrips.value = trips;
    }
  }

  void sortBy(String sortBy) {
    switch (sortBy) {
      case 'departure':
        filteredTrips.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        break;
      case 'price':
        filteredTrips.sort((a, b) => a.fare.compareTo(b.fare));
        break;
      case 'duration':
        filteredTrips.sort((a, b) {
          final aDuration = a.arrivalTime.difference(a.departureTime);
          final bDuration = b.arrivalTime.difference(b.departureTime);
          return aDuration.compareTo(bDuration);
        });
        break;
      default:
        filteredTrips.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    }
  }

  // TESTING METHODS (optional - you can remove these if not needed)
  Future<void> testTripParsing() async {
    try {
      final response = await http.get(
        Uri.parse('https://busticketing-tq3o.onrender.com/api/trips'),
      );
      
      final responseData = json.decode(response.body);
      print('API Response Type: ${responseData.runtimeType}');
      
      if (responseData is List) {
        print('First trip sample:');
        final firstTrip = Trip.fromJson(responseData[0]);
        print('Trip ID: ${firstTrip.id}');
        print('Departure: ${firstTrip.departureTime}');
        print('Arrival: ${firstTrip.arrivalTime}');
        print('Fare: ${firstTrip.fare}');
        print('Bus: ${firstTrip.bus?.busNumber}');
        print('Route: ${firstTrip.route?.origin} → ${firstTrip.route?.destination}');
      }
    } catch (e) {
      print('Test Parsing Error: $e');
    }
  }

  Future<void> testTripAPI() async {
    try {
      final response = await http.get(
        Uri.parse('https://busticketing-tq3o.onrender.com/api/trips'),
      );
      print('RAW TRIPS API RESPONSE: ${response.body}');
      print('RESPONSE TYPE: ${response.body.runtimeType}');
      
      final decoded = json.decode(response.body);
      print('DECODED TYPE: ${decoded.runtimeType}');
      print('DECODED CONTENT: $decoded');
    } catch (e) {
      print('TEST ERROR: $e');
    }
  }
}