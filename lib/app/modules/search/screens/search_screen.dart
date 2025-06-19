import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sq_connect/app/config/app_colors.dart';
import 'package:sq_connect/app/modules/feed/feed_controller.dart';
import 'package:sq_connect/app/modules/feed/widgets/post_card.dart'; // For displaying post results
import 'package:sq_connect/app/modules/search/screens/widgets/user_search_tile.dart';
import 'package:sq_connect/app/modules/search/search_controller.dart';
import 'package:sq_connect/app/routes/app_routes.dart';
import 'package:sq_connect/app/ui/global_widgets/loading_indicator.dart';

class SearchScreen extends GetView<SearchUserController> {
  SearchScreen({super.key});

  final FeedController feedController =
      Get.isRegistered<FeedController>()
          ? Get.find<FeedController>()
          : Get.put(FeedController(Get.find())); // For liking posts from search

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller.searchTec,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search Saher Connect...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[600]),
          ),
          style: const TextStyle(fontSize: 18),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => controller.performSearch(),
        ),
        actions: [
          Obx(
            () =>
                controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: controller.clearSearch,
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [_buildFilterTabs(), Expanded(child: _buildSearchResults())],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            SearchFilter.values.map((filter) {
              return Obx(
                () => TextButton(
                  onPressed: () => controller.changeFilter(filter),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    foregroundColor:
                        controller.currentFilter.value == filter
                            ? AppColors.primary
                            : AppColors.darkGrey,
                  ),
                  child: Text(
                    filter.toString().split('.').last.capitalizeFirst!,
                    style: TextStyle(
                      fontWeight:
                          controller.currentFilter.value == filter
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: LoadingIndicator());
      }
      if (controller.errorMessage.value.isNotEmpty &&
          controller.userResults.isEmpty &&
          controller.postResults.isEmpty) {
        return Center(child: Text(controller.errorMessage.value));
      }
      if (controller.searchQuery.value.isEmpty) {
        return const Center(
          child: Text('Start typing to search for users or posts.'),
        );
      }

      final showUsers =
          controller.currentFilter.value == SearchFilter.all ||
          controller.currentFilter.value == SearchFilter.users;
      final showPosts =
          controller.currentFilter.value == SearchFilter.all ||
          controller.currentFilter.value == SearchFilter.posts;

      if (controller.userResults.isEmpty && controller.postResults.isEmpty) {
        return Center(
          child: Text(
            'No results found for "${controller.searchQuery.value}".',
          ),
        );
      }

      List<Widget> results = [];

      if (showUsers && controller.userResults.isNotEmpty) {
        if (controller.currentFilter.value == SearchFilter.all) {
          results.add(
            Padding(
              padding: const EdgeInsets.all(16.0).copyWith(bottom: 8),
              child: Text("Users", style: Get.textTheme.titleLarge),
            ),
          );
        }
        results.addAll(
          controller.userResults
              .map((user) => UserSearchTile(user: user))
              .toList(),
        );
      }

      if (showPosts && controller.postResults.isNotEmpty) {
        if (controller.currentFilter.value == SearchFilter.all &&
            results.isNotEmpty) {
          results.add(const Divider(height: 32));
        }
        if (controller.currentFilter.value == SearchFilter.all) {
          results.add(
            Padding(
              padding: const EdgeInsets.all(16.0).copyWith(bottom: 8),
              child: Text("Posts", style: Get.textTheme.titleLarge),
            ),
          );
        }
        results.addAll(
          controller.postResults
              .map(
                (post) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: PostCard(
                    post: post,
                    onLikeToggle:
                        () => feedController.likeUnlikePost(
                          post.id,
                        ), // You might need a way to update post state globally or pass a FeedController/PostRepository
                    onCommentTap:
                        () => Get.toNamed(
                          Routes.POST_DETAIL,
                          arguments: {'postId': post.id},
                        ),
                    onProfileTap:
                        () => Get.toNamed(
                          Routes.PROFILE,
                          arguments: {'userId': post.user.id},
                        ),
                  ),
                ),
              )
              .toList(),
        );
      }

      return ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: results,
      );
    });
  }
}
