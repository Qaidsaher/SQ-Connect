// post_detail_controller.dart
import 'package:get/get.dart';
import 'package:sq_connect/app/data/models/comment_model.dart';
import 'package:sq_connect/app/data/models/post_model.dart';
import 'package:sq_connect/app/data/repositories/post_repository.dart';
import 'package:sq_connect/app/modules/auth/auth_controller.dart'; // For current user ID

class PostDetailController extends GetxController {
  final PostRepository _postRepository;
  final int postId;

  PostDetailController(this._postRepository, this.postId);

  final Rx<Post?> post = Rx<Post?>(null);
  final RxList<Comment> comments = <Comment>[].obs;
  final RxBool isLoadingPost = true.obs;
  final RxBool isLoadingComments = true.obs;
  final RxBool isSendingComment = false.obs;
  final RxString postError = ''.obs;
  final RxString commentsError = ''.obs;

  final AuthController _authController = Get.find();

  @override
  void onInit() {
    super.onInit();
    fetchPostDetails();
    fetchComments();
  }

  Future<void> fetchPostDetails() async {
    isLoadingPost.value = true;
    postError.value = '';
    try {
      final response = await _postRepository.getPost(postId);
      if (response.success && response.data != null) {
        post.value = response.data;
      } else {
        postError.value = response.message;
      }
    } catch (e) {
      postError.value = "Failed to load post: ${e.toString()}";
    } finally {
      isLoadingPost.value = false;
    }
  }

  Future<void> fetchComments({bool refresh = false}) async {
    if (refresh) {
      comments.clear();
    }
    isLoadingComments.value = true;
    commentsError.value = '';
    try {
      final response = await _postRepository.getCommentsForPost(postId);
      if (response.success && response.data != null) {
        comments.assignAll(response.data!);
      } else {
        commentsError.value = response.message;
      }
    } catch (e) {
      commentsError.value = "Failed to load comments: ${e.toString()}";
    } finally {
      isLoadingComments.value = false;
    }
  }

  Future<void> addComment(String content, {int? parentCommentId}) async {
    if (content.trim().isEmpty) return;
    isSendingComment.value = true;
    try {
      final response = await _postRepository.createComment(postId, content.trim(), parentCommentId: parentCommentId);
      if (response.success && response.data != null) {
        // If it's a top-level comment, add to start of list.
        // If it's a reply, you might need to find the parent and add to its replies list (more complex UI update)
        // For simplicity, we'll just refresh all comments for now.
        await fetchComments(refresh: true);
        Get.snackbar("Success", "Comment posted!", snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Error", response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to post comment: ${e.toString()}", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSendingComment.value = false;
    }
  }

  // Helper for like/unlike from post card if shown on this page
  Future<void> likeUnlikePost() async {
    if (post.value == null) return;

    final currentPost = post.value!;
    final wasLiked = currentPost.isLiked ?? false;
    final originalLikesCount = currentPost.likesCount ?? 0;

    // Optimistic update
    post.value = currentPost.copyWith(
        isLiked: !wasLiked,
        likesCount: wasLiked ? originalLikesCount - 1 : originalLikesCount + 1
    );

    try {
      final response = wasLiked
          ? await _postRepository.unlikePost(currentPost.id)
          : await _postRepository.likePost(currentPost.id);

      if (response.success && response.data != null) {
         post.value = currentPost.copyWith(
            isLiked: !wasLiked,
            likesCount: response.data!['likes_count'] as int
        );
      } else {
        post.value = currentPost.copyWith(isLiked: wasLiked, likesCount: originalLikesCount);
      }
    } catch (e) {
      post.value = currentPost.copyWith(isLiked: wasLiked, likesCount: originalLikesCount);
    }
    // Notify FeedController if this post is also on the feed to update it there
    // This can be done via a GetX service or by passing a callback if needed.
  }
}