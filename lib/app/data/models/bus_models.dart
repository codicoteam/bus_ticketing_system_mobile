// lib/data/models/bus_models.dart
class BusSeat {
  final String number;
  final bool isAvailable;
  final String type;
  final String id;

  BusSeat({
    required this.number,
    required this.isAvailable,
    required this.type,
    required this.id,
  });

  factory BusSeat.fromJson(Map<String, dynamic> json) {
    return BusSeat(
      number: json['number'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      type: json['type'] ?? 'standard',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "number": number,
        "isAvailable": isAvailable,
        "type": type,
        "_id": id,
      };
}

class Bus {
  final String id;
  final String busNumber;
  final String operatorName; // Changed from 'operator' to avoid keyword conflict
  final String model;
  final int capacity;
  final List<String> amenities;
  final List<BusSeat> seats;
  final bool isActive;
  
  // Optional fields
  final String name;
  final String type;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final double price;
  final double? rating;
  final int availableSeats;
  final String imageUrl;
  final String origin;
  final String destination;
  final double? originalPrice;

  Bus({
    required this.id,
    required this.busNumber,
    required this.operatorName, // Updated parameter name
    required this.model,
    required this.capacity,
    required this.amenities,
    required this.seats,
    required this.isActive,
    
    // Optional fields with defaults
    this.name = '',
    this.type = 'Standard',
    this.departureTime,
    this.arrivalTime,
    this.price = 0.0,
    this.rating,
    this.availableSeats = 0,
    this.imageUrl = '',
    this.origin = '',
    this.destination = '',
    this.originalPrice,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['_id'] ?? '',
      busNumber: json['busNumber'] ?? '',
      operatorName: json['operator'] ?? '', // Map JSON 'operator' to Dart 'operatorName'
      model: json['model'] ?? '',
      capacity: json['capacity'] ?? 0,
      amenities: List<String>.from(json['amenities'] ?? []),
      seats: (json['seats'] as List?)?.map((x) => BusSeat.fromJson(x)).toList() ?? [],
      isActive: json['isActive'] ?? true,
      
      // Optional fields
      name: json['name'] ?? '',
      type: json['type'] ?? 'Standard',
      departureTime: json['departureTime'] != null ? DateTime.parse(json['departureTime']) : null,
      arrivalTime: json['arrivalTime'] != null ? DateTime.parse(json['arrivalTime']) : null,
      price: (json['price'] ?? 0.0).toDouble(),
      rating: json['rating']?.toDouble(),
      availableSeats: json['availableSeats'] ?? json['capacity'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      originalPrice: json['originalPrice']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "busNumber": busNumber,
        "operator": operatorName, // Map Dart 'operatorName' back to JSON 'operator'
        "model": model,
        "capacity": capacity,
        "amenities": amenities,
        "seats": seats.map((seat) => seat.toJson()).toList(),
        "isActive": isActive,
        "name": name,
        "type": type,
        "departureTime": departureTime?.toIso8601String(),
        "arrivalTime": arrivalTime?.toIso8601String(),
        "price": price,
        "rating": rating,
        "availableSeats": availableSeats,
        "imageUrl": imageUrl,
        "origin": origin,
        "destination": destination,
        "originalPrice": originalPrice,
      };

  // Helper getter for display purposes
  String get displayName {
    if (name.isNotEmpty) return name;
    return '$operatorName $busNumber';
  }

  // Helper method to check if bus has specific amenity
  bool hasAmenity(String amenity) {
    return amenities.any((a) => a.toLowerCase().contains(amenity.toLowerCase()));
  }

  // Helper method to get available seats count
  int get actualAvailableSeats {
    return seats.where((seat) => seat.isAvailable).length;
  }
}

class BusResponse {
  final bool success;
  final String message;
  final List<Bus> buses;

  BusResponse({
    required this.success,
    required this.message,
    required this.buses,
  });

  factory BusResponse.fromJson(Map<String, dynamic> json) {
    return BusResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      buses: (json['buses'] as List?)?.map((x) => Bus.fromJson(x)).toList() ?? [],
    );
  }

  factory BusResponse.error(String errorMessage) {
    return BusResponse(
      success: false,
      message: errorMessage,
      buses: [],
    );
  }
}