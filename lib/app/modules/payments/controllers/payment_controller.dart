// lib/app/modules/payment/controllers/payment_controller.dart
import 'package:get/get.dart';
import '../../../data/services/payment_service.dart';
import '../../../data/models/payment_models.dart';

class PaymentController extends GetxController {
  final PaymentService _paymentService = Get.find<PaymentService>();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  
  final Rx<PaymentStatus?> currentPaymentStatus = Rx<PaymentStatus?>(null);
  final RxBool isPolling = false.obs;

  // Initiate EcoCash payment
  Future<EcoCashPaymentResponse> initiateEcoCashPayment({
    required String bookingId,
    required String mobileNumber,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final response = await _paymentService.initiateEcoCashPayment(
        bookingId: bookingId,
        mobileNumber: mobileNumber,
      );

      if (response.success) {
        successMessage.value = response.message;
        // Start polling for payment status
        _startPaymentPolling(bookingId);
      } else {
        errorMessage.value = response.message;
      }

      return response;
    } catch (e) {
      errorMessage.value = 'Payment initiation failed: $e';
      return EcoCashPaymentResponse.error(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Check payment status
  Future<PaymentStatusResponse> checkPaymentStatus(String bookingId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _paymentService.getPaymentStatus(bookingId);

      if (response.success && response.paymentStatus != null) {
        currentPaymentStatus.value = response.paymentStatus;
      } else {
        errorMessage.value = response.message;
      }

      return response;
    } catch (e) {
      errorMessage.value = 'Failed to check payment status: $e';
      return PaymentStatusResponse.error(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Test payment connection
  Future<TestPaymentResponse> testPaymentConnection() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _paymentService.testPaymentConnection();

      if (!response.success) {
        errorMessage.value = response.message;
      }

      return response;
    } catch (e) {
      errorMessage.value = 'Connection test failed: $e';
      return TestPaymentResponse(
        success: false,
        message: errorMessage.value,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Start polling for payment status
  void _startPaymentPolling(String bookingId) {
    isPolling.value = true;
    
    // Poll for payment status
    _paymentService.pollPaymentStatus(bookingId).then((response) {
      isPolling.value = false;
      
      if (response.success && response.paymentStatus != null) {
        currentPaymentStatus.value = response.paymentStatus;
        
        if (response.paymentStatus!.isPaid) {
          successMessage.value = 'Payment completed successfully!';
        } else if (response.paymentStatus!.isFailed) {
          errorMessage.value = 'Payment failed. Please try again.';
        }
      } else {
        errorMessage.value = response.message;
      }
    }).catchError((error) {
      isPolling.value = false;
      errorMessage.value = 'Payment status check failed: $error';
    });
  }

  // Clear messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  // Reset payment state
  void resetPayment() {
    isLoading.value = false;
    errorMessage.value = '';
    successMessage.value = '';
    currentPaymentStatus.value = null;
    isPolling.value = false;
  }
}