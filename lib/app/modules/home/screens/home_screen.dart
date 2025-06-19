// home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sq_connect/app/config/app_constants.dart';
import 'package:sq_connect/app/modules/auth/auth_controller.dart';
import 'package:sq_connect/app/modules/feed/feed_controller.dart';
import 'package:sq_connect/app/modules/feed/widgets/post_card.dart';
import 'package:sq_connect/app/modules/home/home_controller.dart';
import 'package:sq_connect/app/modules/profile/screens/profile_screen.dart'; // Placeholder
import 'package:sq_connect/app/modules/search/screens/search_screen.dart';
import 'package:sq_connect/app/routes/app_routes.dart';
import 'package:sq_connect/app/ui/global_widgets/loading_indicator.dart';

class HomeScreen extends GetView<HomeController> {
  HomeScreen({super.key});

  final AuthController authController = Get.find();
  final FeedController feedController = Get.find(); // Injected by HomeBinding

  final List<Widget> _screens = [
    FeedScreen(),
    SearchScreen(), // Search Screen
    const Center(
      child: Text('Notifications Screen - Placeholder'),
    ), // Notifications
    ProfileScreen(
      userId: Get.find<AuthController>().currentUser.value?.id,
    ), // Profile Screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => Get.toNamed(Routes.CREATE_POST),
          ),
          IconButton(
            icon: const Icon(Icons.message_outlined),
            onPressed: () {
              Get.toNamed(Routes.CONVERSATIONS);
              // Get.snackbar("WIP", "Messaging feature coming soon!");
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() => _screens[controller.tabIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // So labels are always visible
          currentIndex: controller.tabIndex.value,
          onTap: controller.changeTabIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// Dedicated FeedScreen widget for clarity
class FeedScreen extends StatelessWidget {
  FeedScreen({super.key});
  final FeedController feedController = Get.find();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !feedController.isLoadingMore.value) {
        feedController.fetchPosts();
      }
    });

    return Obx(() {
      if (feedController.isLoading.value && feedController.posts.isEmpty) {
        return const Center(child: LoadingIndicator());
      }
      if (feedController.errorMessage.value.isNotEmpty &&
          feedController.posts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(feedController.errorMessage.value),
              ElevatedButton(
                onPressed: () => feedController.fetchPosts(refresh: true),
                child: const Text("Retry"),
              ),
            ],
          ),
        );
      }
      if (feedController.posts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No posts yet. Be the first to share!'),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Feed'),
                onPressed: () => feedController.fetchPosts(refresh: true),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => feedController.fetchPosts(refresh: true),
        child: ListView.builder(
          controller: _scrollController,
          itemCount:
              feedController.posts.length +
              (feedController.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == feedController.posts.length &&
                feedController.isLoadingMore.value) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: LoadingIndicator()),
              );
            }
            if (index >= feedController.posts.length)
              return const SizedBox.shrink(); // Should not happen if logic is correct

            final post = feedController.posts[index];
            return PostCard(
              post: post,
              onLikeToggle: () => feedController.likeUnlikePost(post.id),
              onCommentTap:
                  () => Get.toNamed(
                    Routes.POST_DETAIL,
                    arguments: {'postId': post.id},
                  ),
              onShareTap: () {
                Get.snackbar("Share", "Sharing post ${post.id}");
              },
              onProfileTap:
                  () => Get.toNamed(
                    Routes.PROFILE,
                    arguments: {'userId': post.user.id},
                  ),
            );
          },
        ),
      );
    });
  }
}
