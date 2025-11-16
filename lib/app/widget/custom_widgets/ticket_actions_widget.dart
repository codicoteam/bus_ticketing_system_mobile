// lib/app/modules/tickets/views/ticket_actions_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/tickets/controllers/ticket_controller.dart';


class TicketActionsWidget extends StatelessWidget {
  final String bookingId;
  final String pnrNumber;

  const TicketActionsWidget({
    super.key,
    required this.bookingId,
    required this.pnrNumber,
  });

  @override
  Widget build(BuildContext context) {
    final TicketController ticketController = Get.find<TicketController>();

    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Booking Info
        ListTile(
          leading: Icon(Icons.confirmation_number, color: Colors.blue),
          title: Text(
            'PNR: $pnrNumber',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Booking ID: $bookingId'),
        ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Download Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: ticketController.isDownloading.value
                      ? null
                      : () => ticketController.downloadTicket(bookingId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  icon: ticketController.isDownloading.value
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.download),
                  label: Text(
                    ticketController.isDownloading.value 
                        ? 'Downloading...' 
                        : 'Download',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              SizedBox(width: 8),
              
              // Share Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => ticketController.shareTicket(null, bookingId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(Icons.share, size: 18),
                  label: Text(
                    'Share',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              SizedBox(width: 8),
              
              // Email Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: ticketController.isEmailing.value
                      ? null
                      : () => ticketController.emailTicket(bookingId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  icon: ticketController.isEmailing.value
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.email, size: 18),
                  label: Text(
                    ticketController.isEmailing.value 
                        ? 'Sending...' 
                        : 'Email',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Info Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Note: Email service may be temporarily unavailable. Download and share is recommended.',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 16),

        // Messages
        if (ticketController.successMessage.isNotEmpty)
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ticketController.successMessage.value,
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.green[700], size: 20),
                  onPressed: ticketController.clearMessages,
                ),
              ],
            ),
          ),

        if (ticketController.errorMessage.isNotEmpty)
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ticketController.errorMessage.value,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red[700], size: 20),
                  onPressed: ticketController.clearMessages,
                ),
              ],
            ),
          ),
      ],
    ));
  }
}