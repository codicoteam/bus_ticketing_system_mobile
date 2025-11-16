// lib/data/services/route_service.dart
import 'package:get/get.dart';
import '../models/busroute_models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteService extends GetxService {
  final String baseUrl = 'https://busticketing-tq3o.onrender.com/api';

  Future<RouteResponse> getAllRoutes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/routes'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Routes Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Handle both List and Map responses
        if (responseData is List) {
          // API returns a list of routes directly
          final List<BusRoute> routes = responseData.map((routeJson) => BusRoute.fromJson(routeJson)).toList();
          return RouteResponse(
            success: true,
            message: 'Routes fetched successfully',
            routes: routes,
          );
        } else if (responseData is Map && responseData.containsKey('routes')) {
          // API returns a Map with "routes" field
          final List<BusRoute> routes = (responseData['routes'] as List)
              .map((routeJson) => BusRoute.fromJson(routeJson))
              .toList();
          return RouteResponse(
            success: true,
            message: 'Routes fetched successfully',
            routes: routes,
          );
        } else {
          return RouteResponse.error('Invalid response format from routes API');
        }
      } else {
        return RouteResponse.error('Failed to fetch routes. Please try again.');
      }
    } catch (e) {
      print('Routes Error: $e');
      return RouteResponse.error('Network error. Please check your connection.');
    }
  }
}