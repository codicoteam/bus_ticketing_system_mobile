import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../booking/views/booking_screen.dart';
import '../controllers/bus_controller.dart';

class BusesScreen extends StatefulWidget {
  final String from, to;
  final DateTime date;

  const BusesScreen({
    super.key,
    required this.from,
    required this.to,
    required this.date,
  });

  @override
  State<BusesScreen> createState() => _BusesScreenState();
}

class _BusesScreenState extends State<BusesScreen> {
  final BusController _busController = Get.find<BusController>();
  String _sortBy = 'departure';

  // In your BusesScreen, update the initState to also fetch routes if needed
@override
void initState() {
  super.initState();
  _busController.fetchAllBuses();
  // You can also fetch routes here if you need additional route data
}
// In your BusesScreen, update the get _buses method:
List<Map<String, dynamic>> get _buses {
  // Get buses that match the searched route
  final availableBuses = _busController.getAvailableBuses(widget.from, widget.to, widget.date);
  
  // Convert real bus data to your UI format
  return availableBuses.map((bus) {
    return _busController.convertBusToUiFormat(bus, widget.from, widget.to, widget.date);
  }).toList();
}

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
            Obx(() => Text(
                  "${_busController.buses.length} buses available",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                )),
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
      body: Obx(() {
        if (_busController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (_busController.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  _busController.errorMessage.value,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _busController.fetchAllBuses,
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (_busController.buses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_bus, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No buses available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: _sortedBuses.length,
          itemBuilder: (context, index) => _buildBusCard(_sortedBuses[index]),
        );
      }),
    );
  }

// In your HomeScreen, update the _buildRouteCard method:
  
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
            builder: (_) => BookingScreen(
              tripId: bus["tripId"]!, // Add tripId here
              busName: bus["name"]!, 
              price: bus["price"]!,
              departure: widget.from, // Pass departure
              arrival: widget.to,     // Pass arrival
              date: "${widget.date.day}/${widget.date.month}/${widget.date.year}", // Pass date
            ),
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
                            builder: (_) => BookingScreen(
                              tripId: bus["tripId"]!, // Add tripId here
                              busName: bus["name"]!,
                              price: bus["price"]!,
                              departure: widget.from, // Pass departure
                              arrival: widget.to,     // Pass arrival
                              date: "${widget.date.day}/${widget.date.month}/${widget.date.year}", // Pass date
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