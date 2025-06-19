import 'package:sq_connect/app/data/models/api_response_model.dart';
import 'package:sq_connect/app/data/models/notification_model.dart';
import 'package:sq_connect/app/data/providers/api_provider.dart';

class NotificationRepository {
  final ApiProvider _apiProvider;

  NotificationRepository(this._apiProvider);

  /// Fetch paginated list of notifications
  Future<ApiResponse<List<AppNotification>>> getNotifications({int page = 1}) {
    return _apiProvider.getNotifications(page: page);
  }

  /// Mark a single notification as read
  Future<ApiResponse<void>> markNotificationAsRead(String notificationId) {
    return _apiProvider.markNotificationAsRead(notificationId);
  }

  /// Mark all notifications as read
  Future<ApiResponse<void>> markAllNotificationsAsRead() {
    return _apiProvider.markAllNotificationsAsRead();
  }

  /// Delete a notification (optional)
  Future<ApiResponse<void>> deleteNotification(String notificationId) {
    return _apiProvider.deleteNotification(notificationId);
  }
}
