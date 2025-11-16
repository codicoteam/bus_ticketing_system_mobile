// lib/app/modules/tickets/controllers/ticket_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/services/ticket_service.dart';
import '../../../data/models/ticket_models.dart';

class TicketController extends GetxController {
  final TicketService _ticketService = Get.find<TicketService>();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  final RxBool isDownloading = false.obs;
  final RxBool isEmailing = false.obs;
  final RxString currentFilePath = ''.obs;

  // Download ticket
  Future<TicketDownloadResponse> downloadTicket(String bookingId) async {
    try {
      isDownloading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final response = await _ticketService.downloadTicket(bookingId);

      if (response.success) {
        successMessage.value = 'Ticket downloaded successfully!';
        currentFilePath.value = response.filePath ?? '';
        
        // Open the PDF file if available
        if (response.filePath != null && response.filePath!.isNotEmpty) {
          await _openPdfFile(response.filePath!);
        }
        
        // Show share option
        if (response.filePath != null && response.filePath!.isNotEmpty) {
          _showShareOption(response.filePath!, bookingId);
        }
      } else {
        errorMessage.value = response.message;
      }

      return response;
    } catch (e) {
      errorMessage.value = 'Download failed: $e';
      return TicketDownloadResponse.error(errorMessage.value);
    } finally {
      isDownloading.value = false;
    }
  }

  // Email ticket
  Future<TicketEmailResponse> emailTicket(String bookingId) async {
    try {
      isEmailing.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final response = await _ticketService.emailTicket(bookingId);

      // In your TicketController emailTicket method, update the error message:
if (response.success) {
  successMessage.value = 'Ticket emailed successfully! Please check your inbox.';
} else {
  errorMessage.value = 'Email service is currently unavailable. Please download the ticket instead.\n\nError: ${response.message}';
}

      return response;
    } catch (e) {
      errorMessage.value = 'Email failed: $e\n\nYou can still download the ticket and share it manually.';
      return TicketEmailResponse.error(errorMessage.value);
    } finally {
      isEmailing.value = false;
    }
  }

  // Share ticket
  Future<void> shareTicket(String? filePath, String bookingId) async {
    try {
      // If no filePath provided, use the current file path
      final pathToShare = filePath ?? currentFilePath.value;
      
      if (pathToShare.isNotEmpty && await File(pathToShare).exists()) {
        await Share.shareXFiles(
          [XFile(pathToShare)], 
          text: 'Your bus ticket - PNR: $bookingId'
        );
        successMessage.value = 'Ticket shared successfully!';
      } else {
        // If file doesn't exist, try to download it first
        errorMessage.value = 'Ticket file not found. Please download the ticket first.';
        Get.snackbar(
          'File Not Found',
          'Please download the ticket first to share it.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Error sharing ticket: $e';
    }
  }

  // Open PDF file
  Future<void> _openPdfFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      
      if (result.type != ResultType.done) {
        print('Could not open PDF file: ${result.message}');
        // Don't show error to user for this, it's not critical
      }
    } catch (e) {
      print('Error opening PDF: $e');
      // Don't show error to user for this, it's not critical
    }
  }

  // Show share option after download
  void _showShareOption(String filePath, String bookingId) {
    Get.snackbar(
      '✅ Ticket Downloaded',
      'Would you like to share your ticket?',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      mainButton: TextButton(
        onPressed: () => shareTicket(filePath, bookingId),
        child: const Text(
          'SHARE',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      duration: const Duration(seconds: 5),
    );
  }

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  void resetPayment() {
    isLoading.value = false;
    errorMessage.value = '';
    successMessage.value = '';
    isDownloading.value = false;
    isEmailing.value = false;
    currentFilePath.value = '';
  }
}