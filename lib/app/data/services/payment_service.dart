// lib/data/services/payment_service.dart
import 'package:get/get.dart';
import '../models/payment_models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class PaymentService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final String baseUrl = 'https://busticketing-tq3o.onrender.com/api';

  // EcoCash Payment
  Future<EcoCashPaymentResponse> initiateEcoCashPayment({
    required String bookingId,
    required String mobileNumber,
  }) async {
    try {
      // Check if user is authenticated
      if (!_authService.isAuthenticated) {
        return EcoCashPaymentResponse.error('User not authenticated. Please login.');
      }

      final headers = _authService.getAuthHeaders();
      
      print('EcoCash Payment Headers: $headers');

      final response = await http.post(
        Uri.parse('$baseUrl/payments/ecocash'),
        headers: headers,
        body: json.encode({
          'bookingId': bookingId,
          'mobile': mobileNumber,
        }),
      );

      print('EcoCash Payment Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return EcoCashPaymentResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // Token is invalid - clear auth data
        await _authService.clearAuthData();
        return EcoCashPaymentResponse.error('Session expired. Please login again.');
      } else {
        return EcoCashPaymentResponse.error(
            'Payment initiation failed: ${response.statusCode}');
      }
    } catch (e) {
      print('EcoCash Payment Error: $e');
      return EcoCashPaymentResponse.error('Network error: $e');
    }
  }

  // Check Payment Status
  Future<PaymentStatusResponse> getPaymentStatus(String bookingId) async {
    try {
      // Check if user is authenticated
      if (!_authService.isAuthenticated) {
        return PaymentStatusResponse.error('User not authenticated. Please login.');
      }

      final headers = _authService.getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/payments/status/$bookingId'),
        headers: headers,
      );

      print('Payment Status Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return PaymentStatusResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        await _authService.clearAuthData();
        return PaymentStatusResponse.error('Session expired. Please login again.');
      } else {
        return PaymentStatusResponse.error(
            'Failed to get payment status: ${response.statusCode}');
      }
    } catch (e) {
      print('Payment Status Error: $e');
      return PaymentStatusResponse.error('Network error: $e');
    }
  }

  // Test Payment Connection
  Future<TestPaymentResponse> testPaymentConnection() async {
    try {
      // Check if user is authenticated
      if (!_authService.isAuthenticated) {
        return TestPaymentResponse(
          success: false,
          message: 'User not authenticated. Please login.',
        );
      }

      final headers = _authService.getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/payments/test-paynow'),
        headers: headers,
      );

      print('Test Payment Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return TestPaymentResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        await _authService.clearAuthData();
        return TestPaymentResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return TestPaymentResponse(
          success: false,
          message: 'Payment service test failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Test Payment Error: $e');
      return TestPaymentResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // Poll payment status
  Future<PaymentStatusResponse> pollPaymentStatus(
    String bookingId, {
    int maxAttempts = 10,
    int intervalSeconds = 5,
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final statusResponse = await getPaymentStatus(bookingId);
      
      if (statusResponse.success && statusResponse.paymentStatus != null) {
        final status = statusResponse.paymentStatus!.status.toLowerCase();
        
        // Stop polling if payment is completed (paid or failed)
        if (status == 'paid' || status == 'failed' || status == 'confirmed') {
          return statusResponse;
        }
      }
      
      // Wait before next attempt
      if (attempt < maxAttempts - 1) {
        await Future.delayed(Duration(seconds: intervalSeconds));
      }
    }
    
    return PaymentStatusResponse.error('Payment status polling timeout');
  }
}