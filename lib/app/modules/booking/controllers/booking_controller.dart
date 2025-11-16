// lib/app/modules/booking/controllers/booking_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/booking_models.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/booking_service.dart';

class BookingController extends GetxController {
  final BookingService _bookingService = Get.find<BookingService>();
  final AuthService _authService = Get.find<AuthService>();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<BookingResponse> createBooking({
    required String tripId,
    required List<Seat> seats,
    required int totalAmount,
    required List<PassengerDetail> passengerDetails,
    required String boardingPoint,
    required String droppingPoint,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Check authentication before proceeding
      if (!_authService.isAuthenticated) {
        errorMessage.value = 'Please login to book tickets';
        return BookingResponse.error('Please login to book tickets');
      }

      final bookingData = BookingRequest(
        tripId: tripId,
        seats: seats,
        totalAmount: totalAmount,
        passengerDetails: passengerDetails,
        boardingPoint: boardingPoint,
        droppingPoint: droppingPoint,
      );
      
      final response = await _bookingService.createBooking(bookingData);
      
      if (!response.success) {
        errorMessage.value = response.message;
        
        // If it's an auth error, show login prompt
        if (response.message.contains('login') || 
            response.message.contains('Session expired') ||
            response.message.contains('Please login')) {
          _showLoginPrompt();
        }
      }
      
      return response;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
      return BookingResponse.error('An unexpected error occurred.');
    } finally {
      isLoading.value = false;
    }
  }

  void _showLoginPrompt() {
    // You can show a dialog or snackbar suggesting login
    Get.snackbar(
      'Authentication Required',
      'Please login to continue with booking',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}