// lib/data/models/ticket_models.dart
import 'dart:typed_data' show Uint8List;

class TicketDownloadResponse {
  final bool success;
  final String message;
  final String? filePath;
  final Uint8List? pdfData;

  TicketDownloadResponse({
    required this.success,
    required this.message,
    this.filePath,
    this.pdfData,
  });

  factory TicketDownloadResponse.fromJson(Map<String, dynamic> json) {
    return TicketDownloadResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Ticket downloaded successfully',
      filePath: json['filePath'],
    );
  }

  factory TicketDownloadResponse.error(String errorMessage) {
    return TicketDownloadResponse(
      success: false,
      message: errorMessage,
    );
  }
}

class TicketEmailResponse {
  final bool success;
  final String message;

  TicketEmailResponse({
    required this.success,
    required this.message,
  });

  factory TicketEmailResponse.fromJson(Map<String, dynamic> json) {
    return TicketEmailResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Ticket emailed successfully',
    );
  }

  factory TicketEmailResponse.error(String errorMessage) {
    return TicketEmailResponse(
      success: false,
      message: errorMessage,
    );
  }
}