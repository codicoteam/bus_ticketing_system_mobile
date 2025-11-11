import 'package:flutter/material.dart';
import 'booking_screen.dart';

class BusListPage extends StatefulWidget {
  final String from, to;
  final DateTime date;

  const BusListPage({
    super.key,
    required this.from,
    required this.to,
    required this.date,
  });

  @override
  State<BusListPage> createState() => _BusListPageState();
}

class _BusListPageState extends State<BusListPage> {
  String _sortBy = 'departure';

  List<Map<String, dynamic>> get _buses => [
    {
      "name": "RedBus",
      "type": "AC Sleeper (2+1)",
      "departureTime": "06:00 AM",
      "arrivalTime": "02:00 PM",
      "duration": "8h 0m",
      "price": "\$25",
      "originalPrice": "\$30",
      "rating": "4.5",
      "seats": 12,
      "amenities": ["wifi", "charging", "water", "blanket"],
      "image":
          "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400",
    },
    {
      "name": "VRL Travels",
      "type": "AC Seater (2+2)",
      "departureTime": "07:30 AM",
      "arrivalTime": "02:00 PM",
      "duration": "6h 30m",
      "price": "\$18",
      "rating": "4.2",
      "seats": 8,
      "amenities": ["wifi", "charging"],
      "image":
          "https://images.unsplash.com/photo-1570125909232-eb263c188f7e?w=400",
    },
    {
      "name": "Orange Travels",
      "type": "Non-AC Seater (2+3)",
      "departureTime": "08:00 AM",
      "arrivalTime": "03:00 PM",
      "duration": "7h 0m",
      "price": "\$12",
      "rating": "3.8",
      "seats": 20,
      "amenities": ["water"],
      "image":
          "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400",
    },
    {
      "name": "Volvo Luxury",
      "type": "Multi-Axle AC Sleeper",
      "departureTime": "09:00 AM",
      "arrivalTime": "04:30 PM",
      "duration": "7h 30m",
      "price": "\$35",
      "originalPrice": "\$40",
      "rating": "4.8",
      "seats": 5,
      "amenities": ["wifi", "charging", "water", "blanket"],
      "image":
          "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400",
    },
    {
      "name": "SRS Travels",
      "type": "AC Push Back (2+2)",
      "departureTime": "10:30 AM",
      "arrivalTime": "05:00 PM",
      "duration": "6h 30m",
      "price": "\$22",
      "rating": "4.3",
      "seats": 15,
      "amenities": ["wifi", "charging", "water"],
      "image":
          "https://images.unsplash.com/photo-1570125909232-eb263c188f7e?w=400",
    },
    {
      "name": "Greenline Express",
      "type": "Non-AC Seater (2+2)",
      "departureTime": "11:00 AM",
      "arrivalTime": "06:00 PM",
      "duration": "7h 0m",
      "price": "\$15",
      "rating": "4.0",
      "seats": 18,
      "amenities": ["charging", "water"],
      "image":
          "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400",
    },
    {
      "name": "IntrCity SmartBus",
      "type": "AC Sleeper (2+1)",
      "departureTime": "01:00 PM",
      "arrivalTime": "08:30 PM",
      "duration": "7h 30m",
      "price": "\$28",
      "rating": "4.4",
      "seats": 10,
      "amenities": ["wifi", "charging", "water", "blanket"],
      "image":
          "https://images.unsplash.com/photo-1570125909232-eb263c188f7e?w=400",
    },
    {
      "name": "Kallada G4",
      "type": "AC Semi-Sleeper (2+2)",
      "departureTime": "03:00 PM",
      "arrivalTime": "10:00 PM",
      "duration": "7h 0m",
      "price": "\$20",
      "rating": "4.1",
      "seats": 14,
      "amenities": ["charging", "water"],
      "image":
          "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400",
    },
    {
      "name": "Parveen Travels",
      "type": "AC Sleeper (2+1)",
      "departureTime": "08:00 PM",
      "arrivalTime": "05:00 AM",
      "duration": "9h 0m",
      "price": "\$30",
      "rating": "4.6",
      "seats": 7,
      "amenities": ["wifi", "charging", "water", "blanket"],
      "image":
          "https://images.unsplash.com/photo-1570125909232-eb263c188f7e?w=400",
    },
    {
      "name": "Neeta Volvo",
      "type": "AC Sleeper (2+1)",
      "departureTime": "10:00 PM",
      "arrivalTime": "06:30 AM",
      "duration": "8h 30m",
      "price": "\$32",
      "originalPrice": "\$38",
      "rating": "4.7",
      "seats": 6,
      "amenities": ["wifi", "charging", "water", "blanket"],
      "image":
          "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400",
    },
  ];

  List<Map<String, dynamic>> get _sortedBuses {
    final sorted = List<Map<String, dynamic>>.from(_buses);
    switch (_sortBy) {
      case 'price':
        sorted.sort(
          (a, b) => int.parse(
            a["price"]!.replaceAll(RegExp(r'[^\d]'), ''),
          ).compareTo(int.parse(b["price"]!.replaceAll(RegExp(r'[^\d]'), ''))),
        );
        break;
      case 'duration':
        sorted.sort((a, b) => a["duration"]!.compareTo(b["duration"]!));
        break;
      case 'rating':
        sorted.sort(
          (a, b) =>
              double.parse(b["rating"]!).compareTo(double.parse(a["rating"]!)),
        );
        break;
      default:
        sorted.sort(
          (a, b) => a["departureTime"]!.compareTo(b["departureTime"]!),
        );
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.from} → ${widget.to}",
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "${_sortedBuses.length} buses available",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'departure',
                child: Text('Sort by Departure'),
              ),
              PopupMenuItem(value: 'price', child: Text('Sort by Price')),
              PopupMenuItem(value: 'duration', child: Text('Sort by Duration')),
              PopupMenuItem(value: 'rating', child: Text('Sort by Rating')),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _sortedBuses.length,
        itemBuilder: (context, index) => _buildBusCard(_sortedBuses[index]),
      ),
    );
  }

  Widget _buildBusCard(Map<String, dynamic> bus) {
    final amenityIcons = {
      "wifi": Icons.wifi,
      "charging": Icons.charging_station,
      "water": Icons.local_drink,
      "blanket": Icons.bed,
    };

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                BookingPage(busName: bus["name"]!, price: bus["price"]!),
          ),
        ),
        child: Column(
          children: [
            // Bus Image
            Image.network(
              bus["image"]!,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 140,
                color: Colors.grey[300],
                child: Icon(
                  Icons.directions_bus,
                  size: 50,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bus["name"]!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              bus["type"]!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text(
                              bus["rating"]!,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.star, color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bus["departureTime"]!,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.from,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              bus["duration"]!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey[400]),
                                ),
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Colors.grey[400],
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey[400]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              bus["arrivalTime"]!,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.to,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_seat,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: 4),
                          Text(
                            "${bus['seats']} seats",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      ...((bus["amenities"] as List).map(
                        (a) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              amenityIcons[a],
                              size: 16,
                              color: Colors.grey[700],
                            ),
                            SizedBox(width: 4),
                            Text(
                              a.toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                  Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bus["price"]!,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          if (bus["originalPrice"] != null)
                            Text(
                              bus["originalPrice"]!,
                              style: TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingPage(
                              busName: bus["name"]!,
                              price: bus["price"]!,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text("View Seats"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
