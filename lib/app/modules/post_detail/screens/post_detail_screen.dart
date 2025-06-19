// post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sq_connect/app/modules/feed/widgets/post_card.dart'; // Re-use PostCard
import 'package:sq_connect/app/modules/post_detail/post_detail_controller.dart';
import 'package:sq_connect/app/modules/post_detail/widgets/comment_tile.dart';
import 'package:sq_connect/app/ui/global_widgets/loading_indicator.dart';
import 'package:sq_connect/app/routes/app_routes.dart'; // For profile navigation

class PostDetailScreen extends GetView<PostDetailController> {
  PostDetailScreen({super.key});

  final _commentTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),
      body: Obx(() {
        if (controller.isLoadingPost.value) {
          return const Center(child: LoadingIndicator());
        }
        if (controller.postError.value.isNotEmpty) {
          return Center(child: Text(controller.postError.value));
        }
        if (controller.post.value == null) {
          return const Center(child: Text('Post not found.'));
        }

        final post = controller.post.value!;

        return Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: PostCard(
                      post: post,
                      onLikeToggle: controller.likeUnlikePost,
                      onCommentTap: () {}, // Already on comment screen
                      onShareTap: () { /* Implement share */ },
                      onProfileTap: () => Get.toNamed(Routes.PROFILE, arguments: {'userId': post.user.id}),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Obx(() {
                    if (controller.isLoadingComments.value && controller.comments.isEmpty) {
                      return const SliverToBoxAdapter(child: Center(child: LoadingIndicator()));
                    }
                    if (controller.commentsError.value.isNotEmpty) {
                      return SliverToBoxAdapter(child: Center(child: Text(controller.commentsError.value)));
                    }
                    if (controller.comments.isEmpty) {
                      return const SliverToBoxAdapter(child: Center(child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No comments yet. Be the first!'),
                      )));
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final comment = controller.comments[index];
                          return CommentTile(
                            comment: comment,
                            onReply: (content, parentId) { // Placeholder for advanced reply UI
                               _commentTextController.text = "@${comment.user.username} ";
                               _commentTextController.selection = TextSelection.fromPosition(TextPosition(offset: _commentTextController.text.length));
                               // FocusScope.of(context).requestFocus(commentFocusNode); // Need a FocusNode
                               // controller.setParentCommentIdForReply(comment.id);
                            }
                          );
                        },
                        childCount: controller.comments.length,
                      ),
                    );
                  }),
                ],
              ),
            ),
            _buildCommentInputField(context),
          ],
        );
      }),
    );
  }

  Widget _buildCommentInputField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentTextController,
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4)
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ),
          Obx(() => controller.isSendingComment.value
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2,)),
                )
              : IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_commentTextController.text.trim().isNotEmpty) {
                      controller.addComment(_commentTextController.text.trim());
                      _commentTextController.clear();
                      FocusScope.of(context).unfocus(); // Hide keyboard
                    }
                  },
                )),
        ],
      ),
    );
  }
}