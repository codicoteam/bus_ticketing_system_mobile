class BookingRequest {
  final String tripId;
  final List<Seat> seats;
  final int totalAmount;
  final List<PassengerDetail> passengerDetails;
  final String boardingPoint;
  final String droppingPoint;

  BookingRequest({
    required this.tripId,
    required this.seats,
    required this.totalAmount,
    required this.passengerDetails,
    required this.boardingPoint,
    required this.droppingPoint,
  });

  Map<String, dynamic> toJson() => {
    "tripId": tripId,
    "seats": seats.map((x) => x.toJson()).toList(),
    "totalAmount": totalAmount,
    "passengerDetails": passengerDetails.map((x) => x.toJson()).toList(),
    "boardingPoint": boardingPoint,
    "droppingPoint": droppingPoint,
  };
}

class Seat {
  final String number;
  final int fare;

  Seat({
    required this.number,
    required this.fare,
  });

  // Add fromJson factory method
  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      number: json['number'] ?? '',
      fare: json['fare'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "number": number,
    "fare": fare,
  };
}

class PassengerDetail {
  final String name;
  final int age;
  final String gender;
  final String idType;
  final String idNumber;

  PassengerDetail({
    required this.name,
    required this.age,
    required this.gender,
    required this.idType,
    required this.idNumber,
  });

  // Add fromJson factory method
  factory PassengerDetail.fromJson(Map<String, dynamic> json) {
    return PassengerDetail(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      idType: json['idType'] ?? '',
      idNumber: json['idNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "age": age,
    "gender": gender,
    "idType": idType,
    "idNumber": idNumber,
  };
}

class BookingResponse {
  final bool success;
  final String message;
  final BookingData? booking;

  BookingResponse({
    required this.success,
    required this.message,
    this.booking,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      success: json['success'] ?? true, // Default to true if not provided
      message: json['message'] ?? 'Booking created successfully',
      booking: json['_id'] != null ? BookingData.fromJson(json) : null, // Check for booking ID
    );
  }

  factory BookingResponse.error(String errorMessage) {
    return BookingResponse(
      success: false,
      message: errorMessage,
    );
  }
}

class BookingData {
  final String id;
  final String tripId;
  final List<Seat> seats;
  final int totalAmount;
  final List<PassengerDetail> passengerDetails;
  final String status;
  final DateTime createdAt;

  BookingData({
    required this.id,
    required this.tripId,
    required this.seats,
    required this.totalAmount,
    required this.passengerDetails,
    required this.status,
    required this.createdAt,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      id: json['_id'] ?? '',
      tripId: json['tripId'] ?? '',
      seats: (json['seats'] as List?)?.map((x) => Seat.fromJson(x)).toList() ?? [],
      totalAmount: json['totalAmount'] ?? 0,
      passengerDetails: (json['passengerDetails'] as List?)?.map((x) => PassengerDetail.fromJson(x)).toList() ?? [],
      status: json['status'] ?? 'confirmed',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tripId': tripId,
    'seats': seats.map((x) => x.toJson()).toList(),
    'totalAmount': totalAmount,
    'passengerDetails': passengerDetails.map((x) => x.toJson()).toList(),
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };
}