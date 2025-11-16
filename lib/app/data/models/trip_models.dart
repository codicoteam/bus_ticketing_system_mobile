// lib/data/models/trip_models.dart

class Trip {
  final String id;
  final String busId;
  final String routeId;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double fare;
  final List<String> availableSeats;
  final Bus? bus;
  final BusRoute? route; // Changed from Route to BusRoute to avoid conflict
  final Map<String, dynamic>? driver;
  final String status;
  final bool isActive;

  Trip({
    required this.id,
    required this.busId,
    required this.routeId,
    required this.departureTime,
    required this.arrivalTime,
    required this.fare,
    required this.availableSeats,
    this.bus,
    this.route,
    this.driver,
    required this.status,
    required this.isActive,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    // Handle nested bus object (can be null, string, or object)
    Bus? bus;
    if (json['busId'] != null) {
      if (json['busId'] is Map) {
        bus = Bus.fromJson(json['busId']);
      }
    }

    // Handle nested route object (can be null, string, or object)
    BusRoute? route;
    if (json['routeId'] != null) {
      if (json['routeId'] is Map) {
        route = BusRoute.fromJson(json['routeId']);
      }
    }

    // Handle driver object
    Map<String, dynamic>? driver;
    if (json['driver'] != null && json['driver'] is Map) {
      driver = Map<String, dynamic>.from(json['driver']);
    }

    // Extract IDs from nested objects if they exist
    final String extractedBusId = json['busId'] is Map 
        ? (json['busId']?['_id'] ?? '') 
        : (json['busId']?.toString() ?? '');

    final String extractedRouteId = json['routeId'] is Map 
        ? (json['routeId']?['_id'] ?? '') 
        : (json['routeId']?.toString() ?? '');

    return Trip(
      id: json['_id'] ?? '',
      busId: extractedBusId,
      routeId: extractedRouteId,
      departureTime: DateTime.parse(json['departureTime']),
      arrivalTime: DateTime.parse(json['arrivalTime']),
      fare: (json['fare'] ?? 0).toDouble(),
      availableSeats: List<String>.from(json['availableSeats'] ?? []),
      bus: bus,
      route: route,
      driver: driver,
      status: json['status'] ?? 'scheduled',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        "busId": busId,
        "routeId": routeId,
        "departureTime": departureTime.toIso8601String(),
        "arrivalTime": arrivalTime.toIso8601String(),
        "fare": fare,
        "availableSeats": availableSeats,
        "status": status,
        "isActive": isActive,
      };

  String get duration {
    final difference = arrivalTime.difference(departureTime);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}

class Bus {
  final String id;
  final String busNumber;
  final String operator;
  final String model;
  final int capacity;
  final List<String> amenities;
  final bool isActive;

  Bus({
    required this.id,
    required this.busNumber,
    required this.operator,
    required this.model,
    required this.capacity,
    required this.amenities,
    required this.isActive,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['_id'] ?? '',
      busNumber: json['busNumber'] ?? '',
      operator: json['operator'] ?? '',
      model: json['model'] ?? '',
      capacity: json['capacity'] ?? 0,
      amenities: List<String>.from(json['amenities'] ?? []),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "busNumber": busNumber,
        "operator": operator,
        "model": model,
        "capacity": capacity,
        "amenities": amenities,
        "isActive": isActive,
      };
}

class BusRoute { // Renamed from Route to avoid conflict with Flutter's Route class
  final String id;
  final String name;
  final String origin;
  final String destination;
  final double distance;
  final int duration; // in minutes
  final String arrivalTime;
  final String departureTime;
  final double baseFare;
  final bool isActive;
  final List<dynamic> stops;

  BusRoute({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.distance,
    required this.duration,
    required this.arrivalTime,
    required this.departureTime,
    required this.baseFare,
    required this.isActive,
    required this.stops,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      distance: (json['distance'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      arrivalTime: json['arrivalTime'] ?? '',
      departureTime: json['departureTime'] ?? '',
      baseFare: (json['baseFare'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      stops: List<dynamic>.from(json['stops'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "origin": origin,
        "destination": destination,
        "distance": distance,
        "duration": duration,
        "arrivalTime": arrivalTime,
        "departureTime": departureTime,
        "baseFare": baseFare,
        "isActive": isActive,
        "stops": stops,
      };
}

class TripResponse {
  final bool success;
  final String message;
  final List<Trip> trips;

  TripResponse({
    required this.success,
    required this.message,
    required this.trips,
  });

  factory TripResponse.fromJson(Map<String, dynamic> json) {
    return TripResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      trips: (json['trips'] as List?)?.map((x) => Trip.fromJson(x)).toList() ?? [],
    );
  }

  factory TripResponse.error(String error) {
    return TripResponse(
      success: false,
      message: error,
      trips: [],
    );
  }
}