// lib/app/modules/notifications/controllers/notification_controller.dart
import 'package:get/get.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/models/notification_models.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = Get.find<NotificationService>();
  
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  // Fetch all notifications
  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _notificationService.getNotifications();

      if (response.success) {
        notifications.assignAll(response.notifications);
        // Update unread count
        unreadCount.value = notifications.where((n) => !n.isRead).length;
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch notifications: $e';
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _notificationService.markAsRead(notificationId);

      if (response.success) {
        // Update local state
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(isRead: true);
          unreadCount.value = notifications.where((n) => !n.isRead).length;
        }
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = 'Failed to mark as read: $e';
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final unreadNotifications = notifications.where((n) => !n.isRead).toList();
      
      for (final notification in unreadNotifications) {
        await markAsRead(notification.id);
      }
    } catch (e) {
      errorMessage.value = 'Failed to mark all as read: $e';
    }
  }

  // Refresh notifications
  Future<void> refreshNotifications() async {
    isRefreshing.value = true;
    await fetchNotifications();
  }

  // Get unread count from server
  Future<void> fetchUnreadCount() async {
    try {
      final response = await _notificationService.getUnreadCount();

      if (response.success) {
        unreadCount.value = response.count;
      }
    } catch (e) {
      print('Failed to fetch unread count: $e');
    }
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }
}

// Extension for copying NotificationModel
extension NotificationModelCopyWith on NotificationModel {
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}