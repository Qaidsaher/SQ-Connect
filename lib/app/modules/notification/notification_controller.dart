import 'package:get/get.dart';
import 'package:sq_connect/app/data/models/notification_model.dart';
import 'package:sq_connect/app/data/repositories/notification_repository.dart';
import 'package:sq_connect/app/routes/app_routes.dart';
import 'package:sq_connect/app/ui/utils/helpers.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NotificationController extends GetxController {
  final NotificationRepository _notificationRepository;

  NotificationController(this._notificationRepository);

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedFilter = 'all'.obs;

  int _currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications(initialLoad: true);
  }

  List<AppNotification> get filteredNotifications {
    switch (selectedFilter.value) {
      case 'read':
        return notifications.where((n) => n.read).toList();
      case 'unread':
        return notifications.where((n) => !n.read).toList();
      default:
        return notifications;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<void> fetchNotifications({
    bool refresh = false,
    bool initialLoad = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      notifications.clear();
      hasMore.value = true;
      isLoading.value = true;
      errorMessage.value = '';
    } else if (initialLoad) {
      isLoading.value = true;
    } else {
      if (!hasMore.value || isLoadingMore.value || isLoading.value) return;
      isLoadingMore.value = true;
    }

    try {
      final response = await _notificationRepository.getNotifications(
        page: _currentPage,
      );
      if (response.success && response.data != null) {
        if (response.data!.isEmpty) {
          hasMore.value = false;
        } else {
          notifications.addAll(response.data!);
          _currentPage++;
        }
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = "Unexpected error: ${e.toString()}";
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    final response = await _notificationRepository.markAllNotificationsAsRead();
    if (response.success) {
      notifications.value = notifications.map((n) => n..read = true).toList();
    } else {
      UIHelpers.showErrorSnackbar(response.message);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || notifications[index].read) return;

    try {
      final response = await _notificationRepository.markNotificationAsRead(
        notificationId,
      );
      if (response.success) {
        notifications[index].read = true;
        notifications.refresh();
      } else {
        UIHelpers.showErrorSnackbar(response.message);
      }
    } catch (_) {
      UIHelpers.showErrorSnackbar("Failed to mark notification as read.");
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final original = notifications[index];
    notifications.removeAt(index); // Optimistic

    try {
      final response = await _notificationRepository.deleteNotification(
        notificationId,
      );
      if (!response.success) {
        notifications.insert(index, original);
        UIHelpers.showErrorSnackbar(response.message);
      }
    } catch (_) {
      notifications.insert(index, original);
      UIHelpers.showErrorSnackbar("Failed to delete notification.");
    }
  }

  Future<void> handleNotificationTap(AppNotification notification) async {
    if (!notification.read) {
      await markAsRead(notification.id);
    }

    if (notification.postId != null) {
      Get.toNamed(
        Routes.POST_DETAIL,
        arguments: {'postId': notification.postId},
      );
    } else if (notification.url != null) {
      launchUrlString(notification.url!);
    } else if (notification.userId != null) {
      Get.toNamed(Routes.PROFILE, arguments: {'userId': notification.userId});
    } else {
      // fallback
      UIHelpers.showInfoSnackbar("Notification opened.");
    }
  }
}
