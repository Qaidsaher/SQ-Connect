import 'package:get/get.dart';
import 'package:sq_connect/app/data/models/post_model.dart';
import 'package:sq_connect/app/data/repositories/post_repository.dart';
import 'package:sq_connect/app/ui/utils/helpers.dart'; // For snackbars

class FeedController extends GetxController {
  final PostRepository _postRepository;
  FeedController(this._postRepository);

  final RxList<Post> posts = <Post>[].obs;
  final RxBool isLoading = true.obs; // Initial loading state
  final RxBool isLoadingMore = false.obs; // For pagination
  final RxString errorMessage = ''.obs;
  final RxBool hasMorePosts = true.obs; // To know if more posts can be fetched
  int _currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    fetchPosts(initialLoad: true);
  }

  Future<void> fetchPosts({bool refresh = false, bool initialLoad = false}) async {
    if (refresh) {
      _currentPage = 1;
      posts.clear();
      hasMorePosts.value = true;
      isLoading.value = true; // Show main loading indicator
      errorMessage.value = '';
    } else if (initialLoad) {
      isLoading.value = true;
    } else {
      // If not refresh and not initial, it's loading more
      if (!hasMorePosts.value || isLoadingMore.value || isLoading.value) return;
      isLoadingMore.value = true;
    }
    
    errorMessage.value = ''; // Clear previous errors

    try {
      final response = await _postRepository.getPosts(page: _currentPage);
      if (response.success && response.data != null) {
        if (response.data!.isEmpty) {
          hasMorePosts.value = false;
        } else {
          posts.addAll(response.data!);
          _currentPage++;
        }
      } else {
        errorMessage.value = response.message;
        // Consider not setting hasMorePosts to false on temporary error unless it's a specific "no more data" error
      }
    } catch (e) {
      errorMessage.value = "An unexpected error occurred: ${e.toString()}";
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> likeUnlikePost(int postId) async {
    final postIndex = posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = posts[postIndex];
    final bool originalIsLiked = post.isLiked;
    final int originalLikesCount = post.likesCount;

    // Optimistic UI update
    posts[postIndex] = post.copyWith(
      isLiked: !originalIsLiked,
      likesCount: originalIsLiked ? (originalLikesCount - 1).clamp(0, 1000000) : originalLikesCount + 1,
    );

    try {
      final response = originalIsLiked
          ? await _postRepository.unlikePost(postId)
          : await _postRepository.likePost(postId);

      if (response.success && response.data != null) {
        // Update with actual count from server if different (though often not needed if API is consistent)
         posts[postIndex] = posts[postIndex].copyWith( // Use the optimistically updated post as base
            likesCount: response.data!['likes_count'] as int
            // isLiked should already match from optimistic update
        );
      } else {
        // Revert optimistic update on failure
        posts[postIndex] = post.copyWith(isLiked: originalIsLiked, likesCount: originalLikesCount);
        UIHelpers.showErrorSnackbar(response.message);
      }
    } catch (e) {
      // Revert optimistic update on exception
      posts[postIndex] = post.copyWith(isLiked: originalIsLiked, likesCount: originalLikesCount);
      UIHelpers.showErrorSnackbar("Could not ${originalIsLiked ? 'unlike' : 'like'} post.");
    }
  }

  void removePostFromFeed(int postId) {
    posts.removeWhere((post) => post.id == postId);
  }

  void updatePostInFeed(Post updatedPost) {
    final index = posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      posts[index] = updatedPost;
    }
  }
}