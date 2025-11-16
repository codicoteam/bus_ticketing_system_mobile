// lib/data/models/notification_models.dart
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? json['body'] ?? '',
      type: _parseNotificationType(json['type'] ?? 'general'),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
      case 'ticket':
        return NotificationType.booking;
      case 'payment':
      case 'transaction':
        return NotificationType.payment;
      case 'reminder':
      case 'schedule':
        return NotificationType.reminder;
      case 'promotion':
      case 'offer':
        return NotificationType.promotion;
      case 'alert':
      case 'warning':
        return NotificationType.alert;
      default:
        return NotificationType.general;
    }
  }
}

class NotificationResponse {
  final bool success;
  final String message;
  final List<NotificationModel> notifications;

  NotificationResponse({
    required this.success,
    required this.message,
    required this.notifications,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    final notifications = (json['notifications'] ?? json['data'] ?? [])
        .map<NotificationModel>((item) => NotificationModel.fromJson(item))
        .toList();
    
    return NotificationResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Notifications fetched successfully',
      notifications: notifications,
    );
  }

  factory NotificationResponse.error(String errorMessage) {
    return NotificationResponse(
      success: false,
      message: errorMessage,
      notifications: [],
    );
  }
}

class MarkAsReadResponse {
  final bool success;
  final String message;

  MarkAsReadResponse({
    required this.success,
    required this.message,
  });

  factory MarkAsReadResponse.fromJson(Map<String, dynamic> json) {
    return MarkAsReadResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Notification marked as read',
    );
  }

  factory MarkAsReadResponse.error(String errorMessage) {
    return MarkAsReadResponse(
      success: false,
      message: errorMessage,
    );
  }
}

class UnreadCountResponse {
  final bool success;
  final String message;
  final int count;

  UnreadCountResponse({
    required this.success,
    required this.message,
    required this.count,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Unread count fetched successfully',
      count: json['count'] ?? json['unreadCount'] ?? 0,
    );
  }

  factory UnreadCountResponse.error(String errorMessage) {
    return UnreadCountResponse(
      success: false,
      message: errorMessage,
      count: 0,
    );
  }
}

enum NotificationType {
  booking,
  payment,
  reminder,
  promotion,
  alert,
  general
}