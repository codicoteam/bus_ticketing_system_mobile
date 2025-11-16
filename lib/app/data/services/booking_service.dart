// lib/app/data/services/booking_service.dart
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/booking_models.dart';
import 'auth_service.dart';

class BookingService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  
  final String baseUrl = 'https://busticketing-tq3o.onrender.com/api';

  Future<BookingResponse> createBooking(BookingRequest bookingData) async {
    try {
      // Check if user is authenticated
      if (!_authService.isAuthenticated) {
        return BookingResponse(
          success: false,
          message: 'Please login to book tickets',
        );
      }

      final headers = _authService.getAuthHeaders();
      
      // Debug print to check headers
      print('Booking Headers: $headers');
      print('Booking Request: ${bookingData.toJson()}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: headers,
        body: json.encode(bookingData.toJson()),
      );

      print('Booking Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return BookingResponse(
          success: true,
          message: 'Booking created successfully',
          booking: BookingData.fromJson(responseData),
        );
      } else if (response.statusCode == 401) {
        // Token is invalid - clear auth data
        await _authService.clearAuthData();
        return BookingResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return BookingResponse(
          success: false,
          message: errorData['message'] ?? 'Booking failed. Please try again.',
        );
      }
    } catch (e) {
      print('Booking Error: $e');
      return BookingResponse.error('Network error. Please check your connection.');
    }
  }
}


  // You can add more methods here for:
  // - Getting user's bookings
  // - Canceling bookings
  // - Getting booking details
