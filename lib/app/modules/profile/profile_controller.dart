// profile_controller.dart

import 'package:get/get.dart';
import 'package:sq_connect/app/data/models/api_response_model.dart';
import 'package:sq_connect/app/data/models/post_model.dart';
import 'package:sq_connect/app/data/models/user_model.dart';
import 'package:sq_connect/app/data/repositories/post_repository.dart'; // For liking/unliking posts
import 'package:sq_connect/app/data/repositories/user_repository.dart';
import 'package:sq_connect/app/modules/auth/auth_controller.dart';
import 'package:sq_connect/app/ui/utils/helpers.dart';

class ProfileController extends GetxController {
  final UserRepository _userRepository;
  final AuthController _authController;
  final PostRepository _postRepository = Get.find(); // For post actions
  final int? userId; // The ID of the profile being viewed
  final RxBool isFollowing =
      false.obs; // Is the auth user following the currently viewed profile?
  final RxBool isProcessingFollow =
      false.obs; // For loading state of follow/unfollow button
  final RxBool followStatusKnown =
      false.obs; // To only show button once status is determined

  // To hold initial counts for optimistic updates if user model doesn't update immediately
  final RxInt initialFollowersCount = 0.obs;
  final RxInt initialFollowingCount = 0.obs;

  ProfileController({
    required UserRepository userRepository,
    required AuthController authController,
    this.userId,
  }) : _userRepository = userRepository,
       _authController = authController;

  final Rx<User?> userProfile = Rx<User?>(null);
  final RxList<Post> userPosts = <Post>[].obs;
  final RxBool isLoadingProfile = true.obs;
  final RxBool isLoadingPosts = true.obs;
  final RxString profileError = ''.obs;
  final RxString postsError = ''.obs;

  bool get isCurrentUserProfile =>
      userId == null || userId == _authController.currentUser.value?.id;

  @override
  void onInit() {
    super.onInit();
    final targetUserId = userId ?? _authController.currentUser.value?.id;
    if (targetUserId != null) {
      fetchUserProfile(targetUserId);
      fetchUserPosts(targetUserId);
      
    } else {
      profileError.value = "User ID not available.";
      postsError.value = "User ID not available.";
      isLoadingProfile.value = false;
      isLoadingPosts.value = false;
    }
  }

  Future<void> fetchUserProfile(int id) async {
    isLoadingProfile.value = true;
    profileError.value = '';
    try {
      final response = await _userRepository.getUserProfile(id);
      if (response.success && response.data != null) {
        userProfile.value = response.data;
         isFollowing.value = response.data!.isFollowedByAuthUser ?? false;
        initialFollowersCount.value = response.data!.followersCount ?? 0;
        initialFollowingCount.value = response.data!.followingCount ?? 0;
        followStatusKnown.value = true;
      } else {
        profileError.value = response.message;
      }
    } catch (e) {
      profileError.value = "Failed to load profile: ${e.toString()}";
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> fetchUserPosts(int id, {bool refresh = false}) async {
    if (refresh) userPosts.clear();
    isLoadingPosts.value = true;
    postsError.value = '';
    try {
      final response = await _userRepository.getUserPosts(id);
      if (response.success && response.data != null) {
        userPosts.assignAll(response.data!);
      } else {
        postsError.value = response.message;
      }
    } catch (e) {
      postsError.value = "Failed to load posts: ${e.toString()}";
    } finally {
      isLoadingPosts.value = false;
    }
  }

  // Copied from FeedController for like/unlike functionality on profile posts
  Future<void> likeUnlikePost(int postId) async {
    final postIndex = userPosts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = userPosts[postIndex];
    final wasLiked = post.isLiked ?? false;
    final originalLikesCount = post.likesCount ?? 0;

    userPosts[postIndex] = post.copyWith(
      isLiked: !wasLiked,
      likesCount: wasLiked ? originalLikesCount - 1 : originalLikesCount + 1,
    );

    try {
      final response =
          wasLiked
              ? await _postRepository.unlikePost(postId)
              : await _postRepository.likePost(postId);

      if (response.success && response.data != null) {
        userPosts[postIndex] = post.copyWith(
          isLiked: !wasLiked,
          likesCount: response.data!['likes_count'] as int,
        );
      } else {
        userPosts[postIndex] = post.copyWith(
          isLiked: wasLiked,
          likesCount: originalLikesCount,
        );
      }
    } catch (e) {
      userPosts[postIndex] = post.copyWith(
        isLiked: wasLiked,
        likesCount: originalLikesCount,
      );
    }
  }

  void refreshProfileAndPosts() {
    final targetUserId = userId ?? _authController.currentUser.value?.id;
    if (targetUserId != null) {
      fetchUserProfile(targetUserId);
      fetchUserPosts(targetUserId, refresh: true);
    }
  }
  Future<void> toggleFollow() async {
    if (userProfile.value == null || isCurrentUserProfile) return;

    isProcessingFollow.value = true;
    final targetUser = userProfile.value!;
    final bool currentlyFollowing = isFollowing.value;

    // Optimistic UI update
    isFollowing.value = !currentlyFollowing;
    if (isFollowing.value) { // Just followed
        userProfile.value = targetUser.copyWith(
            followersCount: (targetUser.followersCount ?? initialFollowersCount.value) + 1
        );
    } else { // Just unfollowed
         userProfile.value = targetUser.copyWith(
            followersCount: ((targetUser.followersCount ?? initialFollowersCount.value) - 1).clamp(0, 10000000)
        );
    }


    try {
      ApiResponse<dynamic> response;
      if (isFollowing.value) { // Action was to follow
        response = await _userRepository.followUser(targetUser.id);
      } else { // Action was to unfollow
        response = await _userRepository.unfollowUser(targetUser.id);
      }

      if (!response.success) {
        // Revert optimistic update
        isFollowing.value = currentlyFollowing;
        userProfile.value = targetUser.copyWith(followersCount: targetUser.followersCount ?? initialFollowersCount.value); // Revert count
        UIHelpers.showErrorSnackbar(response.message);
      } else {
        // Success, UI is already updated optimistically.
        // Optionally, refetch profile to get exact server counts if API doesn't return them.
        // For instance, if the follow/unfollow API also returns the new follower_count for targetUser:
        // if (response.data != null && response.data['followers_count'] != null) {
        //   userProfile.value = userProfile.value?.copyWith(followersCount: response.data['followers_count']);
        // }
        UIHelpers.showSuccessSnackbar(response.message);
      }
    } catch (e) {
      // Revert optimistic update on exception
      isFollowing.value = currentlyFollowing;
      userProfile.value = targetUser.copyWith(followersCount: targetUser.followersCount ?? initialFollowersCount.value);
      UIHelpers.showErrorSnackbar("An error occurred: ${e.toString()}");
    } finally {
      isProcessingFollow.value = false;
    }
  }
}
