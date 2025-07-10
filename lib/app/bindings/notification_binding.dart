// notification_binding.dart
import 'package:get/get.dart';
import 'package:sq_connect/app/data/repositories/notification_repository.dart';
import 'package:sq_connect/app/modules/notification/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(
      () => NotificationController(Get.find<NotificationRepository>()),
      fenix: true,
    );
  }
}
