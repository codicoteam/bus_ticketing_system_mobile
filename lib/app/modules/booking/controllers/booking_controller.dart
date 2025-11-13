import 'package:get/get.dart';
import '../../../data/models/booking_models.dart';
import '../../../data/services/booking_service.dart';

class BookingController extends GetxController {
  final BookingService _bookingService = Get.find<BookingService>();
  
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
      }
      
      return response;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
      return BookingResponse.error('An unexpected error occurred.');
    } finally {
      isLoading.value = false;
    }
  }
}