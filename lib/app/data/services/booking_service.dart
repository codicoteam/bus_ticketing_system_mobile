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
      final headers = _authService.getAuthHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: headers,
        body: json.encode(bookingData.toJson()),
      );

      print('Booking Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        // SUCCESS: API returns 201 with booking data directly
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Create a successful response - your API doesn't return "success" field
        return BookingResponse(
          success: true, // Manually set to true for 201 responses
          message: 'Booking created successfully',
          booking: BookingData.fromJson(responseData), // Parse the booking data
        );
      } else {
        //ERROR: Handle other status codes
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
  // You can add more methods here for:
  // - Getting user's bookings
  // - Canceling bookings
  // - Getting booking details
}