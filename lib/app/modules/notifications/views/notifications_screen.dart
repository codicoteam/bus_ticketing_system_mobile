// lib/app/modules/notifications/views/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/notification_models.dart';
import '../controllers/notification_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController _notificationController = Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();
    // Fetch notifications when screen loads
    _notificationController.fetchNotifications();
    _notificationController.fetchUnreadCount();
  }

  void _markAsRead(String id) {
    _notificationController.markAsRead(id);
  }

  void _markAllAsRead() {
    _notificationController.markAllAsRead();
  }

  void _deleteNotification(String id) {
    // Note: Your API doesn't have delete endpoint, so we'll just remove from local list
    _notificationController.notifications.removeWhere((n) => n.id == id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification removed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() {
            if (_notificationController.unreadCount.value > 0) {
              return TextButton.icon(
                onPressed: _markAllAsRead,
                icon: const Icon(Icons.done_all, color: Colors.white, size: 20),
                label: const Text(
                  'Mark all read',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return const SizedBox();
          }),
        ],
      ),
      body: Obx(() {
        if (_notificationController.isLoading.value) {
          return _buildLoadingState();
        }

        if (_notificationController.errorMessage.isNotEmpty) {
          return _buildErrorState();
        }

        if (_notificationController.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return _buildNotificationsList();
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading notifications...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          SizedBox(height: 16),
          Text(
            'Failed to load notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _notificationController.errorMessage.value,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _notificationController.fetchNotifications,
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You\'ll see updates about your bookings here',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return RefreshIndicator(
      onRefresh: () => _notificationController.refreshNotifications(),
      child: Column(
        children: [
          Obx(() {
            if (_notificationController.unreadCount.value > 0) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.blue[50],
                child: Text(
                  '${_notificationController.unreadCount.value} new notification${_notificationController.unreadCount.value > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            return SizedBox();
          }),
          Expanded(
            child: ListView.builder(
              itemCount: _notificationController.notifications.length,
              itemBuilder: (context, index) {
                final notification = _notificationController.notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }
          _handleNotificationTap(notification);
        },
        child: Container(
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : Colors.blue[50],
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(notification.type),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.blue[700],
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _formatTimestamp(notification.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.booking:
        icon = Icons.confirmation_number;
        color = Colors.green;
        break;
      case NotificationType.payment:
        icon = Icons.payment;
        color = Colors.blue;
        break;
      case NotificationType.reminder:
        icon = Icons.schedule;
        color = Colors.orange;
        break;
      case NotificationType.promotion:
        icon = Icons.local_offer;
        color = Colors.purple;
        break;
      case NotificationType.alert:
        icon = Icons.warning;
        color = Colors.red;
        break;
      case NotificationType.general:
        icon = Icons.notifications;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle navigation based on notification type
    switch (notification.type) {
      case NotificationType.booking:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening booking details...')),
        );
        break;
      case NotificationType.payment:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening payment details...')),
        );
        break;
      case NotificationType.reminder:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening ticket...')));
        break;
      case NotificationType.promotion:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening offers...')));
        break;
      case NotificationType.alert:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viewing alert...')));
        break;
      case NotificationType.general:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viewing notification...')));
        break;
    }
  }
}