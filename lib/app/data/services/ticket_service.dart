// lib/data/services/ticket_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;
import '../models/ticket_models.dart';
import 'auth_service.dart';

class TicketService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final String baseUrl = 'https://busticketing-tq3o.onrender.com/api';

  // Download ticket as PDF with file saving
 // In your TicketService, replace the download method with this:
// Updated TicketService with platform detection
Future<TicketDownloadResponse> downloadTicket(String bookingId) async {
  try {
    if (!_authService.isAuthenticated) {
      return TicketDownloadResponse.error('Please login to download tickets');
    }

    final headers = _authService.getAuthHeaders();
    headers['Accept'] = 'application/pdf';

    final response = await http.get(
      Uri.parse('$baseUrl/tickets/$bookingId/download'),
      headers: headers,
    );

    print('Download Ticket Response: ${response.statusCode}');

    if (response.statusCode == 200) {
      // Platform-specific handling
      if (_isWebPlatform()) {
        return _handleWebDownload(response.bodyBytes, bookingId);
      } else {
        return _handleMobileDownload(response.bodyBytes, bookingId);
      }
    } else if (response.statusCode == 401) {
      await _authService.clearAuthData();
      return TicketDownloadResponse.error('Session expired. Please login again.');
    } else {
      return TicketDownloadResponse.error(
        'Failed to download ticket: ${response.statusCode}',
      );
    }
  } catch (e) {
    print('Download Ticket Error: $e');
    return TicketDownloadResponse.error('Download failed: $e');
  }
}

bool _isWebPlatform() {
  return identical(0, 0.0); // Simple web platform detection
}

TicketDownloadResponse _handleWebDownload(Uint8List pdfData, String bookingId) {
  try {
    // Web download using dart:html
    final blob = html.Blob([pdfData], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final fileName = 'bus_ticket_$bookingId.pdf';
    
    // Create and trigger download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    
    // Clean up
    html.Url.revokeObjectUrl(url);
    
    return TicketDownloadResponse(
      success: true,
      message: 'Ticket download started!',
      pdfData: pdfData,
      filePath: fileName,
    );
  } catch (e) {
    return TicketDownloadResponse.error('Web download failed: $e');
  }
}

Future<TicketDownloadResponse> _handleMobileDownload(Uint8List pdfData, String bookingId) async {
  try {
    // Mobile download logic (your existing code)
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      return TicketDownloadResponse.error('Storage permission denied');
    }

    final directory = await getDownloadsDirectory();
    if (directory == null) {
      return TicketDownloadResponse.error('Could not access downloads directory');
    }

    final fileName = 'bus_ticket_$bookingId.pdf';
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    await file.writeAsBytes(pdfData);
    
    return TicketDownloadResponse(
      success: true,
      message: 'Ticket saved to Downloads!',
      pdfData: pdfData,
      filePath: filePath,
    );
  } catch (e) {
    return TicketDownloadResponse.error('Mobile download failed: $e');
  }
}

  // Save PDF to device storage
  Future<String> _savePdfToDevice(Uint8List pdfData, String bookingId) async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }

      // Get downloads directory
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Could not access downloads directory');
      }

      // Create file path
      final fileName = 'bus_ticket_$bookingId.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Write PDF data to file
      await file.writeAsBytes(pdfData);
      
      print('PDF saved to: $filePath');
      return filePath;
    } catch (e) {
      print('Error saving PDF: $e');
      rethrow;
    }
  }

  // Email ticket to customer with improved error handling
  Future<TicketEmailResponse> emailTicket(String bookingId) async {
    try {
      if (!_authService.isAuthenticated) {
        return TicketEmailResponse.error('Please login to email tickets');
      }

      final headers = _authService.getAuthHeaders();

      print('Email Ticket Headers: $headers');
      print('Email Ticket URL: $baseUrl/tickets/$bookingId/email');

      final response = await http.post(
        Uri.parse('$baseUrl/tickets/$bookingId/email'),
        headers: headers,
      );

      print('Email Ticket Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return TicketEmailResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        await _authService.clearAuthData();
        return TicketEmailResponse.error('Session expired. Please login again.');
      } else if (response.statusCode == 403) {
        return TicketEmailResponse.error(
          'Access denied. You may not have permission to email this ticket.',
        );
      } else if (response.statusCode == 500) {
        // Handle server errors specifically
        try {
          final errorData = json.decode(response.body);
          return TicketEmailResponse.error(
            errorData['message'] ?? 'Email service is temporarily unavailable. Please try again later or download the ticket instead.',
          );
        } catch (e) {
          return TicketEmailResponse.error(
            'Email service is temporarily unavailable. Please try again later or download the ticket instead.',
          );
        }
      } else {
        return TicketEmailResponse.error(
          'Failed to email ticket: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Email Ticket Error: $e');
      return TicketEmailResponse.error(
        'Network error. Please check your internet connection and try again.',
      );
    }
  }
}