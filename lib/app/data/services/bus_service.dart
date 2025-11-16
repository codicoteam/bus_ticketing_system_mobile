// lib/data/services/bus_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/bus_models.dart';

class BusService extends GetxService {
  final String baseUrl = 'https://busticketing-tq3o.onrender.com/api';

  Future<BusResponse> getAllBuses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/buses'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Buses Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Check if the response is a List or has a "buses" field
        if (responseData is List) {
          // API returns a list directly
          final List<Bus> buses = responseData.map((busJson) => Bus.fromJson(busJson)).toList();
          return BusResponse(
            success: true,
            message: 'Buses fetched successfully',
            buses: buses,
          );
        } else if (responseData is Map && responseData.containsKey('buses')) {
          // API returns a Map with "buses" field
          final List<Bus> buses = (responseData['buses'] as List)
              .map((busJson) => Bus.fromJson(busJson))
              .toList();
          return BusResponse(
            success: true,
            message: 'Buses fetched successfully',
            buses: buses,
          );
        } else {
          return BusResponse.error('Invalid response format from server');
        }
      } else {
        return BusResponse.error('Failed to fetch buses. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Buses Error: $e');
      return BusResponse.error('Network error. Please check your connection.');
    }
  }

  // Get bus by ID
  Future<Bus?> getBusById(String busId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/buses/$busId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final busJson = json.decode(response.body);
        return Bus.fromJson(busJson);
      } else {
        return null;
      }
    } catch (e) {
      print('Get Bus Error: $e');
      return null;
    }
  }

  // Get buses by operator
  Future<BusResponse> getBusesByOperator(String operator) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/buses?operator=$operator'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData is List) {
          final List<Bus> buses = responseData.map((busJson) => Bus.fromJson(busJson)).toList();
          return BusResponse(
            success: true,
            message: 'Buses fetched successfully',
            buses: buses,
          );
        } else {
          return BusResponse.error('Invalid response format');
        }
      } else {
        return BusResponse.error('Failed to fetch buses by operator');
      }
    } catch (e) {
      return BusResponse.error('Network error: $e');
    }
  }


  // You can add more methods for:
  // - Getting buses by route
  // - Getting bus details by ID
  // - Filtering buses, etc.
}