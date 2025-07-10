import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sq_connect/app/config/app_colors.dart';
import 'package:sq_connect/app/modules/notification/notification_controller.dart';
import 'package:sq_connect/app/modules/notification/screens/widgets/circle_avatar_widget.dart';
import 'package:sq_connect/app/ui/global_widgets/loading_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: LoadingIndicator());
        }

        final notifications = controller.filteredNotifications;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopTabsWithMarkAll(),
            Expanded(
              child:
                  notifications.isEmpty
                      ? const Center(child: Text('No notifications.'))
                      : RefreshIndicator(
                        onRefresh:
                            () => controller.fetchNotifications(refresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return _buildNotificationCard(notification);
                          },
                        ),
                      ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTopTabsWithMarkAll() {
    return Obx(() {
      final selected = controller.selectedFilter.value;
      final hasUnread = controller.notifications.any((n) => !n.read);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                children: [
                  _buildTab(
                    'All',
                    selected == 'all',
                    () => controller.setFilter('all'),
                  ),
                  _buildTab(
                    'Unread',
                    selected == 'unread',
                    () => controller.setFilter('unread'),
                  ),
                  _buildTab(
                    'Read',
                    selected == 'read',
                    () => controller.setFilter('read'),
                  ),
                ],
              ),
            ),
            if (hasUnread)
              TextButton(
                onPressed: controller.markAllAsRead,
                child: const Text(
                  'Mark all as read',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildTab(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color:
              isActive
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(notification) {
    final user = notification.user;
    final isRead = notification.read;

    final icon =
        notification.icon != null
            ? Icon(
              _mapIcon(notification.icon!),
              color: _mapColor(notification.color),
              size: 28,
            )
            : const Icon(Icons.notifications, color: AppColors.primary);

    return InkWell(
      onTap: () => controller.handleNotificationTap(notification),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : AppColors.secondary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user?.avatarUrl != null)
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(user!.avatarUrl!),
              )
            else
              CircleLetterAvatar(letter: notification.icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.username ?? notification.username ?? "Unknown",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message ?? "You have a new notification.",
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        timeago.format(
                          DateTime.tryParse(notification.timestamp ?? '') ??
                              DateTime.now(),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isRead)
              const Padding(
                padding: EdgeInsets.only(left: 6.0),
                child: Icon(Icons.circle, color: AppColors.primary, size: 10),
              ),
          ],
        ),
      ),
    );
  }

  IconData _mapIcon(String icon) {
    switch (icon) {
      case 'comment':
        return Icons.comment;
      case 'like':
        return Icons.favorite;
      case 'follow':
        return Icons.person_add;
      case 'mention':
        return Icons.alternate_email;
      default:
        return Icons.notifications;
    }
  }

  Color _mapColor(String? color) {
    switch (color) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.amber;
      default:
        return AppColors.primary;
    }
  }
}
