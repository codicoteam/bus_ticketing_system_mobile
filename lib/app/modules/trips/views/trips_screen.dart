// lib/app/modules/trips/views/trips_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/trip_models.dart';
import '../../booking/views/booking_screen.dart';
import '../controllers/trip_controller.dart';

class TripsScreen extends StatefulWidget {
  final String from;
  final String to;
  final DateTime date;

  const TripsScreen({
    super.key,
    required this.from,
    required this.to,
    required this.date,
  });

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final TripController _tripController = Get.find<TripController>();
  String _timeFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Search for trips based on the route
    _tripController.searchTrips(widget.from, widget.to);
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
                  "${_tripController.filteredTrips.length} trips available",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                )),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            onSelected: (value) {
              _tripController.sortBy(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'departure',
                child: Text('Sort by Departure'),
              ),
              PopupMenuItem(value: 'price', child: Text('Sort by Price')),
              PopupMenuItem(value: 'duration', child: Text('Sort by Duration')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Time Filter Chips
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.grey[50],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTimeFilterChip('All', 'all'),
                  _buildTimeFilterChip('Morning', 'morning'),
                  _buildTimeFilterChip('Afternoon', 'afternoon'),
                  _buildTimeFilterChip('Evening', 'evening'),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_tripController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

             // In your TripsScreen, update the error handling
if (_tripController.errorMessage.value.isNotEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          _tripController.errorMessage.value,
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            _tripController.fetchAllTrips();
            // Also test the API
            _tripController.testTripAPI(); // Add this method temporarily
          },
          child: Text('Try Again'),
        ),
      ],
    ),
  );
}

              if (_tripController.filteredTrips.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bus, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No trips available for this route',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Try searching for different locations',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _tripController.filteredTrips.length,
                itemBuilder: (context, index) => 
                  _buildTripCard(_tripController.filteredTrips[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: _timeFilter == value,
        onSelected: (selected) {
          setState(() => _timeFilter = value);
          _tripController.filterByTime(value);
        },
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    final amenityIcons = {
      "wifi": Icons.wifi,
      "charging": Icons.charging_station,
      "water": Icons.local_drink,
      "blanket": Icons.bed,
      "AC": Icons.ac_unit,
      "TV": Icons.tv,
    };

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingScreen(
              tripId: trip.id,
              busName: trip.bus?.busNumber ?? 'Bus ${trip.busId}',
              price: '\$${trip.fare}',
              departure: widget.from,
              arrival: widget.to,
              date: "${widget.date.day}/${widget.date.month}/${widget.date.year}",
            ),
          ),
        ),
        child: Padding(
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
                          trip.bus?.operator ?? 'Unknown Operator',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${trip.bus?.model ?? 'Bus'} • ${trip.bus?.busNumber ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '4.5', // You can add rating to your Trip model later
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
                          DateFormat('hh:mm a').format(trip.departureTime),
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
                          trip.duration,
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
                          DateFormat('hh:mm a').format(trip.arrivalTime),
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
              if (trip.bus?.amenities != null && trip.bus!.amenities.isNotEmpty)
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
                          "${trip.availableSeats.length} seats available",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    ...(trip.bus!.amenities.map(
                      (amenity) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            amenityIcons[amenity.toLowerCase()] ?? Icons.check_circle,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: 4),
                          Text(
                            amenity.toUpperCase(),
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
                        '\$${trip.fare}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'Per person',
                        style: TextStyle(
                          fontSize: 12,
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
                          tripId: trip.id,
                          busName: trip.bus?.busNumber ?? 'Bus ${trip.busId}',
                          price: '\$${trip.fare}',
                          departure: widget.from,
                          arrival: widget.to,
                          date: "${widget.date.day}/${widget.date.month}/${widget.date.year}",
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text("View Seats"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}