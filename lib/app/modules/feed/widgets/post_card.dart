import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sq_connect/app/config/app_colors.dart';
import 'package:sq_connect/app/data/models/comment_model.dart'; // Ensure this is correct
import 'package:sq_connect/app/data/models/post_model.dart';
import 'package:sq_connect/app/modules/auth/auth_controller.dart';
import 'package:sq_connect/app/modules/feed/widgets/post_attachments_widget.dart'; // Import the updated widget
import 'package:sq_connect/app/routes/app_routes.dart';
import 'package:sq_connect/app/ui/utils/helpers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:readmore/readmore.dart'; // For expandable text

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLikeToggle;
  final VoidCallback onCommentTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onProfileTap;
  final Function(int postId)? onDeletePost;

  const PostCard({
    super.key,
    required this.post,
    required this.onLikeToggle,
    required this.onCommentTap,
    this.onShareTap,
    this.onProfileTap,
    this.onDeletePost,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final bool isOwnPost = post.userId == authController.currentUser.value?.id;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final Color subtleTextColor = Colors.grey[600]!;


    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0), // Slightly reduced margin
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        // borderRadius: BorderRadius.circular(16.0), // More rounded
        // boxShadow: [ // Softer shadow
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.08),
        //     blurRadius: 10,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
        // No shadow, border bottom for feed style
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.8))
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), // Adjusted padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(context, post, isOwnPost, onDeletePost, onSurfaceColor, subtleTextColor),
            const SizedBox(height: 12),
            if (post.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ReadMoreText(
                  post.content,
                  trimLines: 4,
                  colorClickableText: AppColors.primary,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: 'Show more',
                  trimExpandedText: ' Show less',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5, color: onSurfaceColor.withOpacity(0.85)),
                  moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                  lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            if (post.attachments != null && post.attachments!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: PostAttachmentsWidget(attachments: post.attachments!), // Using the new widget
              ),
            _buildPostActions(context, post, onSurfaceColor),
            const SizedBox(height: 8),
            _buildPostStats(context, post, subtleTextColor), // Likes and comments count
            if (post.sampleComments != null && post.sampleComments!.isNotEmpty)
              _buildSampleComments(context, post.sampleComments!, onSurfaceColor, subtleTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context, Post post, bool isOwnPost, Function(int postId)? onDelete, Color onSurfaceColor, Color subtleTextColor) {
    // ... (Header remains mostly the same, just ensure styling uses passed colors)
    // Example adjustment:
    // Text(post.user.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: onSurfaceColor))
    // Text('@${post.user.username} • ${UIHelpers.formatTimestamp(post.createdAt)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: subtleTextColor))
    final AuthController authController = Get.find(); // Needed here for role check
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onProfileTap ?? () => Get.toNamed(Routes.PROFILE, arguments: {'userId': post.user.id}),
          child: CircleAvatar(
            radius: 20, // Slightly smaller
            backgroundImage: post.user.avatarUrl != null ? CachedNetworkImageProvider(post.user.avatarUrl!) : null,
            child: post.user.avatarUrl == null ? Text(UIHelpers.getInitials(post.user.name), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)) : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: onProfileTap ?? () => Get.toNamed(Routes.PROFILE, arguments: {'userId': post.user.id}),
                      child: Text(
                        post.user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: onSurfaceColor, fontSize: 15),
                      ),
                    ),
                  ),
                  // TODO: Add verified badge if user is verified
                ],
              ),
              Text(
                UIHelpers.formatTimestamp(post.createdAt), // Username removed for cleaner look, it's in profile
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: subtleTextColor, fontSize: 12),
              ),
            ],
          ),
        ),
        if (isOwnPost || authController.currentUser.value?.role == 'admin' || authController.currentUser.value?.role == 'moderator')
          SizedBox( // Constrain size of popup menu button
            width: 36, height: 36,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_horiz_rounded, color: subtleTextColor, size: 20),
              tooltip: "More options",
              onSelected: (value) { /* ... existing logic ... */ },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                 if (isOwnPost)
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(children: [Icon(Icons.edit_outlined, size: 20), SizedBox(width: 8), Text('Edit Post')]),
                    ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(children: [Icon(Icons.delete_outline, color: AppColors.error, size: 20), SizedBox(width: 8), Text('Delete Post')]),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPostStats(BuildContext context, Post post, Color subtleTextColor) {
    bool hasLikes = post.likesCount > 0;
    bool hasComments = post.commentsCount > 0;

    if (!hasLikes && !hasComments) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 8.0), // No top padding if actions above
      child: Row(
        children: [
          if (hasLikes)
            Text.rich(
              TextSpan(children: [
                TextSpan(text: "${post.likesCount}", style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: subtleTextColor)),
                TextSpan(text: post.likesCount == 1 ? " like" : " likes", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: subtleTextColor)),
              ]),
            ),
          if (hasLikes && hasComments)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text("•", style: TextStyle(color: subtleTextColor)),
            ),
          if (hasComments)
            GestureDetector(
              onTap: onCommentTap,
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: "${post.commentsCount}", style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: subtleTextColor)),
                  TextSpan(text: post.commentsCount == 1 ? " comment" : " comments", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: subtleTextColor)),
                ]),
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildPostActions(BuildContext context, Post post, Color onSurfaceColor) {
    // Using FontAwesome for more modern icon style
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5)),
      ),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _PostActionButton(
            icon: post.isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
            label: "Like", // Label can be hidden on smaller screens or based on preference
            count: post.likesCount, // Pass count separately for styling
            isActive: post.isLiked,
            activeColor: AppColors.error,
            onTap: onLikeToggle,
            iconColor: onSurfaceColor,
          ),
          _PostActionButton(
            icon: FontAwesomeIcons.comment,
            label: "Comment",
            count: post.commentsCount,
            onTap: onCommentTap,
            iconColor: onSurfaceColor,
          ),
          _PostActionButton(
            icon: FontAwesomeIcons.shareSquare, // Or FontAwesomeIcons.retweet for repost/reshare
            label: "Share",
            onTap: onShareTap ?? () => UIHelpers.showInfoSnackbar("Share feature coming soon!"),
            iconColor: onSurfaceColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSampleComments(BuildContext context, List<Comment> comments, Color onSurfaceColor, Color subtleTextColor) {
    // Modern comment preview style
    return Padding(
      padding: const EdgeInsets.only(top: 0.0), // No top padding if stats above
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...comments.take(1).map((comment) => Padding( // Show only 1 sample comment for cleaner look
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: onSurfaceColor.withOpacity(0.85)),
                children: [
                  TextSpan(
                    text: "${comment.user.name} ", // Use name for better readability
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: comment.content),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )),
          if (post.commentsCount > 1) // If more than 1 comment total (and we showed 1)
            GestureDetector(
              onTap: onCommentTap,
              child: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  "View all ${post.commentsCount} comments",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: subtleTextColor, fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Updated Helper widget for action buttons
class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count; // Optional count to display
  final bool isActive;
  final Color? activeColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _PostActionButton({
    required this.icon,
    required this.label,
    this.count,
    this.isActive = false,
    this.activeColor,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorToUse = isActive ? (activeColor ?? AppColors.primary) : (iconColor ?? Colors.grey[700]!);
    final bool showCount = count != null && count! > 0;

    return Expanded( // Make buttons take equal space
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8), // Larger touch area
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0), // Increased vertical padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center content
            children: [
              FaIcon(icon, size: 18, color: colorToUse), // FontAwesome icon
              const SizedBox(width: 6),
              Text(
                // Show count if available and > 0, else show label
                showCount ? count.toString() : label,
                style: TextStyle(
                  fontSize: 13,
                  color: colorToUse,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}