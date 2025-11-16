// lib/data/services/notification_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/notification_models.dart';
import 'auth_service.dart';

class NotificationService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final String baseUrl = 'https://busticketing-tq3o.onrender.com/api';

  // Get all notifications
  Future<NotificationResponse> getNotifications() async {
    try {
      if (!_authService.isAuthenticated) {
        return NotificationResponse.error('Please login to view notifications');
      }

      final headers = _authService.getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: headers,
      );

      print('Notifications Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return NotificationResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        await _authService.clearAuthData();
        return NotificationResponse.error('Session expired. Please login again.');
      } else {
        return NotificationResponse.error(
          'Failed to fetch notifications: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get Notifications Error: $e');
      return NotificationResponse.error('Network error: $e');
    }
  }

  // Mark notification as read
  Future<MarkAsReadResponse> markAsRead(String notificationId) async {
    try {
      if (!_authService.isAuthenticated) {
        return MarkAsReadResponse.error('Please login to mark notifications as read');
      }

      final headers = _authService.getAuthHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: headers,
      );

      print('Mark as Read Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return MarkAsReadResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        await _authService.clearAuthData();
        return MarkAsReadResponse.error('Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        return MarkAsReadResponse.error('Notification not found');
      } else {
        return MarkAsReadResponse.error(
          'Failed to mark notification as read: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Mark as Read Error: $e');
      return MarkAsReadResponse.error('Network error: $e');
    }
  }

  // Get unread notifications count
  Future<UnreadCountResponse> getUnreadCount() async {
    try {
      if (!_authService.isAuthenticated) {
        return UnreadCountResponse.error('Please login to get notification count');
      }

      final headers = _authService.getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread/count'),
        headers: headers,
      );

      print('Unread Count Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return UnreadCountResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        await _authService.clearAuthData();
        return UnreadCountResponse.error('Session expired. Please login again.');
      } else {
        return UnreadCountResponse.error(
          'Failed to get unread count: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Unread Count Error: $e');
      return UnreadCountResponse.error('Network error: $e');
    }
  }
}