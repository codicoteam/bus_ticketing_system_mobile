// lib/data/models/route_models.dart

class BusRoute {
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
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    // Safe date parsing with fallbacks
    DateTime safeParseDate(String dateString) {
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return DateTime.now();
      }
    }

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
      createdAt: safeParseDate(json['createdAt']),
      updatedAt: safeParseDate(json['updatedAt']),
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
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };

  // Helper getters for display
  String get displayName {
    if (name.isNotEmpty) return name;
    return '$origin to $destination';
  }

  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    return '${hours}h ${minutes}m';
  }

  String get formattedPrice => '\$$baseFare';

  // Helper method to check if route matches search criteria
  bool matchesSearch(String from, String to) {
    final fromMatch = origin.toLowerCase().contains(from.toLowerCase());
    final toMatch = destination.toLowerCase().contains(to.toLowerCase());
    return fromMatch && toMatch;
  }

  // Helper method to get estimated arrival time
  String get estimatedArrival {
    try {
      // Parse departure time and add duration
      final departure = _parseTimeString(departureTime);
      final arrival = departure.add(Duration(minutes: duration));
      return _formatTime(arrival);
    } catch (e) {
      return arrivalTime; // Fallback to stored arrival time
    }
  }

  // Private helper methods for time parsing
  DateTime _parseTimeString(String timeString) {
    try {
      final now = DateTime.now();
      final parts = timeString.split(' ');
      final timeParts = parts[0].split(':');
      final period = parts.length > 1 ? parts[1] : 'AM';
      
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      // Convert to 24-hour format
      if (period.toUpperCase() == 'PM' && hour < 12) hour += 12;
      if (period.toUpperCase() == 'AM' && hour == 12) hour = 0;
      
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return DateTime.now();
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class RouteResponse {
  final bool success;
  final String message;
  final List<BusRoute> routes;

  RouteResponse({
    required this.success,
    required this.message,
    required this.routes,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    return RouteResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      routes: (json['routes'] as List?)?.map((x) => BusRoute.fromJson(x)).toList() ?? [],
    );
  }

  factory RouteResponse.error(String errorMessage) {
    return RouteResponse(
      success: false,
      message: errorMessage,
      routes: [],
    );
  }

  // Helper method to filter routes by origin and destination
  List<BusRoute> filterByRoute(String from, String to) {
    return routes.where((route) => route.matchesSearch(from, to)).toList();
  }

  // Helper method to get popular routes (you can customize the logic)
  List<BusRoute> get popularRoutes {
    // Simple logic: return first 6 active routes
    return routes.where((route) => route.isActive).take(6).toList();
  }

  // Helper method to find route by ID
  BusRoute? findById(String id) {
    try {
      return routes.firstWhere((route) => route.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Optional: Stop model if you want to type the stops
class RouteStop {
  final String name;
  final double distanceFromOrigin;
  final String arrivalTime;
  final String id;

  RouteStop({
    required this.name,
    required this.distanceFromOrigin,
    required this.arrivalTime,
    required this.id,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      name: json['name'] ?? '',
      distanceFromOrigin: (json['distanceFromOrigin'] ?? 0).toDouble(),
      arrivalTime: json['arrivalTime'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "distanceFromOrigin": distanceFromOrigin,
        "arrivalTime": arrivalTime,
        "_id": id,
      };
}