import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sq_connect/app/modules/feed/widgets/post_card.dart';
import 'package:sq_connect/app/modules/profile/profile_controller.dart';
import 'package:sq_connect/app/routes/app_routes.dart';
import 'package:sq_connect/app/ui/global_widgets/error_message_widget.dart';
import 'package:sq_connect/app/ui/global_widgets/loading_indicator.dart';
import 'package:sq_connect/app/ui/utils/helpers.dart'; // For UIHelpers

class ProfileScreen extends GetView<ProfileController> {
  final int? userId; // This argument is handled by ProfileBinding
  ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We move the AppBar inside the Obx or make it conditional
      // to avoid accessing controller.userProfile.value before it's ready.
      // Alternatively, ProfileController can have an RxString for appBarTitle.
      body: Obx(() {
        // Initial Loading State for the entire profile
        if (controller.isLoadingProfile.value && controller.userProfile.value == null) {
          return Scaffold(appBar: AppBar(title: const Text("Profile")), body: const Center(child: LoadingIndicator()));
        }

        // Error State for fetching profile
        if (controller.profileError.value.isNotEmpty && controller.userProfile.value == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: ErrorMessageWidget(
              message: controller.profileError.value,
              onRetry: () => controller.refreshProfileAndPosts(), // Assuming refreshProfileAndPosts exists
            ),
          );
        }

        // If userProfile is still null after loading and no error, something is unexpected
        if (controller.userProfile.value == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Profile Not Found")),
            body: const Center(child: Text('User profile could not be loaded.')),
          );
        }

        // At this point, controller.userProfile.value is NOT null
        final user = controller.userProfile.value!; // Safe to use ! now

        return RefreshIndicator(
          onRefresh: () async {
            controller.refreshProfileAndPosts();
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                actions: [
                  if (controller.isCurrentUserProfile)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => Get.toNamed(Routes.EDIT_PROFILE),
                    ),
                  // We'll add follow/unfollow button here later
                  if (!controller.isCurrentUserProfile && controller.followStatusKnown.value) // Check if status is known
                     Obx(() => Padding(
                           padding: const EdgeInsets.only(right: 8.0),
                           child: controller.isProcessingFollow.value
                               ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,)))
                               : ElevatedButton(
                                   onPressed: controller.toggleFollow,
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: controller.isFollowing.value ? Colors.grey[700] : Theme.of(context).colorScheme.secondary,
                                     foregroundColor: controller.isFollowing.value ? Colors.white : Theme.of(context).colorScheme.onSecondary,
                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                     padding: const EdgeInsets.symmetric(horizontal: 16)
                                   ),
                                   child: Text(controller.isFollowing.value ? 'Unfollow' : 'Follow'),
                                 ),
                         )),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  centerTitle: true, // Better for longer names with actions
                  title: Text(
                    user.name,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black54)]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: user.avatarUrl!,
                              fit: BoxFit.cover,
                              color: Colors.black.withOpacity(0.4),
                              colorBlendMode: BlendMode.darken,
                              placeholder: (context, url) => Container(color: Colors.grey[300]),
                              errorWidget: (context, url, error) =>
                                  Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 100, color: Colors.grey)),
                            )
                          : Container(color: Theme.of(context).primaryColor.withOpacity(0.7)),
                      Positioned(
                        bottom: 50, // Adjust based on title height
                        left: 0,
                        right: 0,
                        child: Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                                ? CachedNetworkImageProvider(user.avatarUrl!)
                                : null,
                            child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                                ? Text(UIHelpers.getInitials(user.name), style: const TextStyle(fontSize: 40))
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('@${user.username}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700])),
                      const SizedBox(height: 8),
                      if (user.bio != null && user.bio!.isNotEmpty)
                        Text(user.bio!, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      Obx(() => Row( // Make stats reactive for follower count
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn("Posts", controller.userPosts.length.toString()),
                          // Use follower/following counts from ProfileController's userProfile
                          _buildStatColumn("Followers", user.followersCount?.toString() ?? controller.initialFollowersCount.value.toString() ?? "0"),
                          _buildStatColumn("Following", user.followingCount?.toString() ?? controller.initialFollowingCount.value.toString() ?? "0"),
                        ],
                      )),
                      if (!controller.isCurrentUserProfile) // Message button from previous step
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.message_outlined),
                            label: Text('Message ${user.name.split(" ").first}'),
                            onPressed: () {
                              Get.toNamed(Routes.CHAT, arguments: {'otherUser': user});
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ),
                      const Divider(height: 32),
                      Text("Posts by ${user.name}", style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                ),
              ),
              Obx(() { // For user's posts
                if (controller.isLoadingPosts.value && controller.userPosts.isEmpty) {
                  return const SliverToBoxAdapter(child: Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: LoadingIndicator(),
                  )));
                }
                if (controller.postsError.value.isNotEmpty && controller.userPosts.isEmpty) {
                  return SliverToBoxAdapter(child: ErrorMessageWidget(message: controller.postsError.value, onRetry: () => controller.fetchUserPosts(user.id)));
                }
                if (controller.userPosts.isEmpty) {
                  return const SliverToBoxAdapter(child: Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No posts yet.'),
                  )));
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = controller.userPosts[index];
                      return PostCard(
                        post: post,
                        onLikeToggle: () => controller.likeUnlikePost(post.id),
                        onCommentTap: () => Get.toNamed(Routes.POST_DETAIL, arguments: {'postId': post.id}),
                        onShareTap: () { /* ... */ },
                        onProfileTap: () { /* Already on profile, or navigate if different user */ },
                      );
                    },
                    childCount: controller.userPosts.length,
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}