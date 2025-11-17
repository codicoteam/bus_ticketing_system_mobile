// lib/data/services/trip_service.dart
import 'package:get/get.dart';
import '../models/trip_models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TripService extends GetxService {
  final String baseUrl = 'https://busticketing-tq3o.onrender.com/api';

  Future<TripResponse> getAllTrips() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trips'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Trips Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Your API returns a List directly - simplified handling
        if (responseData is List) {
          try {
            final List<Trip> trips = responseData.map((tripJson) => Trip.fromJson(tripJson)).toList();
            return TripResponse(
              success: true,
              message: 'Trips fetched successfully',
              trips: trips,
            );
          } catch (e) {
            print('Trip parsing error: $e');
            return TripResponse.error('Error parsing trip data: $e');
          }
        } else {
          return TripResponse.error('Invalid response format from trips API');
        }
      } else {
        return TripResponse.error('Failed to load trips: ${response.statusCode}');
      }
    } catch (e) {
      print('Trips Error: $e');
      return TripResponse.error('Network error: $e');
    }
  }

Future<TripResponse> getTripsByRoute(String origin, String destination) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/trips'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print('Trips Search Response: ${response.statusCode}');
    print('Searching for: $origin → $destination');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      List<Trip> allTrips = [];

      // Parse the response
      if (responseData is List) {
        try {
          allTrips = responseData.map((tripJson) => Trip.fromJson(tripJson)).toList();
          print('Total trips parsed: ${allTrips.length}');
        } catch (e) {
          print('Trip parsing error in search: $e');
          return TripResponse.error('Error parsing trip data: $e');
        }
      } else {
        return TripResponse.error('Invalid response format');
      }

      // DEBUG: Print all trip routes
      for (var trip in allTrips) {
        if (trip.route != null) {
          print('Trip Route: ${trip.route!.origin} → ${trip.route!.destination}');
        } else {
          print('Trip has no route data');
        }
      }

      // Filter trips by origin and destination (EXACT MATCH)
      final filteredTrips = allTrips.where((trip) {
        if (trip.route == null) {
          print('Skipping trip - no route data');
          return false;
        }
        
        final tripOrigin = trip.route!.origin.toLowerCase().trim();
        final tripDestination = trip.route!.destination.toLowerCase().trim();
        final searchOrigin = origin.toLowerCase().trim();
        final searchDestination = destination.toLowerCase().trim();
        
        final matches = tripOrigin == searchOrigin && tripDestination == searchDestination;
        
        if (matches) {
          print('MATCH FOUND: $tripOrigin → $tripDestination');
        }
        
        return matches;
      }).toList();

      print('Filtered trips count: ${filteredTrips.length}');

      return TripResponse(
        success: true,
        message: filteredTrips.isEmpty 
            ? 'No trips found for $origin to $destination' 
            : '${filteredTrips.length} trips found for $origin to $destination',
        trips: filteredTrips,
      );
    } else {
      return TripResponse.error('Failed to search trips: ${response.statusCode}');
    }
  } catch (e) {
    print('Trips Search Error: $e');
    return TripResponse.error('Search error: $e');
  }
}

  // Optional: Add method to get trips by date
  Future<TripResponse> getTripsByDate(DateTime date) async {
    try {
      final allTripsResponse = await getAllTrips();
      
      if (!allTripsResponse.success) {
        return allTripsResponse;
      }

      final filteredTrips = allTripsResponse.trips.where((trip) {
        return trip.departureTime.year == date.year &&
               trip.departureTime.month == date.month &&
               trip.departureTime.day == date.day;
      }).toList();

      return TripResponse(
        success: true,
        message: filteredTrips.isEmpty
            ? 'No trips found for ${date.toString().split(' ')[0]}'
            : '${filteredTrips.length} trips found',
        trips: filteredTrips,
      );
    } catch (e) {
      print('Trips by date error: $e');
      return TripResponse.error('Error filtering trips by date: $e');
    }
  }
}