import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/bus_models.dart';
import '../controllers/bus_controller.dart';

class BusListScreen extends StatefulWidget {
  const BusListScreen({super.key});

  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  final BusController _busController = Get.find<BusController>();
  
  // List of background image paths
  final List<String> _backgroundImages = [
    'assets/images/yellow_bckgd_blurred.png',
    'assets/images/blue_bckgrd_blur.jpg',
    'assets/images/red_bckgrd_blur.png',
  ];

  @override
  void initState() {
    super.initState();
    _busController.fetchAllBuses();
  }

  // Helper method to get background image in sequence: first, second, third, first, second, third...
  String _getBusBackgroundImage(int index) {
    return _backgroundImages[index % _backgroundImages.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Buses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _busController.fetchAllBuses,
          ),
        ],
      ),
      body: Obx(() {
        if (_busController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_busController.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _busController.errorMessage.value,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _busController.fetchAllBuses,
                  child: const Text('Try Again'),
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
                const Icon(Icons.directions_bus, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No buses available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _busController.fetchAllBuses,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _busController.buses.length,
          itemBuilder: (context, index) => _buildBusCard(_busController.buses[index], index),
        );
      }),
    );
  }

  Widget _buildBusCard(Bus bus, int index) {
    final backgroundImage = _getBusBackgroundImage(index);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Image Section - No text, increased height
          Container(
            height: 180, // Increased height for better visibility
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Content Section - All text content below the image
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bus Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bus.displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${bus.model} • ${bus.type}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: bus.isActive ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          bus.isActive ? 'ACTIVE' : 'INACTIVE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Bus Details
                Row(
                  children: [
                    _buildDetailItem(
                      Icons.confirmation_number,
                      'Bus Number',
                      bus.busNumber,
                    ),
                    const SizedBox(width: 16),
                    _buildDetailItem(
                      Icons.business,
                      'Operator',
                      bus.operatorName,
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    _buildDetailItem(
                      Icons.event_seat,
                      'Total Seats',
                      '${bus.capacity}',
                    ),
                    const SizedBox(width: 16),
                    _buildDetailItem(
                      Icons.event_seat,
                      'Available',
                      '${bus.actualAvailableSeats}',
                    ),
                  ],
                ),
                
                // Amenities
                if (bus.amenities.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Amenities:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: bus.amenities.map((amenity) => Chip(
                      label: Text(
                        amenity,
                        style: const TextStyle(fontSize: 10),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                ],
                
                // Route Information (if available)
                if (bus.origin.isNotEmpty && bus.destination.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Route:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${bus.origin} → ${bus.destination}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (bus.price > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '\$${bus.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}