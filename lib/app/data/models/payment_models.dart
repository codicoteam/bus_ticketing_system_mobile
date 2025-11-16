// lib/data/models/payment_models.dart

class EcoCashPaymentRequest {
  final String bookingId;
  final String mobile;

  EcoCashPaymentRequest({
    required this.bookingId,
    required this.mobile,
  });

  Map<String, dynamic> toJson() => {
        "bookingId": bookingId,
        "mobile": mobile,
      };
}

class EcoCashPaymentResponse {
  final bool success;
  final String message;
  final String? paymentId;
  final String? status;

  EcoCashPaymentResponse({
    required this.success,
    required this.message,
    this.paymentId,
    this.status,
  });

  factory EcoCashPaymentResponse.fromJson(Map<String, dynamic> json) {
    return EcoCashPaymentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      paymentId: json['paymentId'],
      status: json['status'],
    );
  }

  factory EcoCashPaymentResponse.error(String errorMessage) {
    return EcoCashPaymentResponse(
      success: false,
      message: errorMessage,
    );
  }
}

class PaymentStatus {
  final String bookingId;
  final String status;
  final double amount;
  final DateTime? paidAt;
  final String? paymentMethod;

  PaymentStatus({
    required this.bookingId,
    required this.status,
    required this.amount,
    this.paidAt,
    this.paymentMethod,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      bookingId: json['bookingId'] ?? '',
      status: json['status'] ?? 'pending',
      amount: (json['amount'] ?? 0).toDouble(),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      paymentMethod: json['paymentMethod'],
    );
  }

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isFailed => status.toLowerCase() == 'failed';
}

class PaymentStatusResponse {
  final bool success;
  final String message;
  final PaymentStatus? paymentStatus;

  PaymentStatusResponse({
    required this.success,
    required this.message,
    this.paymentStatus,
  });

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    return PaymentStatusResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      paymentStatus: json['paymentStatus'] != null 
          ? PaymentStatus.fromJson(json['paymentStatus'])
          : null,
    );
  }

  factory PaymentStatusResponse.error(String errorMessage) {
    return PaymentStatusResponse(
      success: false,
      message: errorMessage,
    );
  }
}

class TestPaymentResponse {
  final bool success;
  final String message;
  final bool? connectionStatus;

  TestPaymentResponse({
    required this.success,
    required this.message,
    this.connectionStatus,
  });

  factory TestPaymentResponse.fromJson(Map<String, dynamic> json) {
    return TestPaymentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      connectionStatus: json['connectionStatus'],
    );
  }
}