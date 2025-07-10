import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
// --- Project-Specific Imports (Ensure these paths are correct) ---
import 'package:sq_connect/app/config/app_colors.dart';
import 'package:sq_connect/app/data/models/post_model.dart';
import 'package:sq_connect/app/modules/auth/auth_controller.dart';
import 'package:sq_connect/app/modules/feed/widgets/post_attachments_widget.dart';
import 'package:sq_connect/app/routes/app_routes.dart';
import 'package:sq_connect/app/ui/utils/helpers.dart';

/// PostCard: A widget meticulously designed to replicate the modern, clean UI of a post on X.com (Twitter).
///
/// This design features a row-based layout with the avatar on the left and all content
/// flowing vertically in an expanded column on the right. Engagement counts are integrated
/// directly into the action buttons for a seamless and scannable feed experience.
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
    // The main container provides padding and the bottom border for separation.
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).primaryColor, width: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Left Column: Avatar ---
          _Avatar(post: post, onProfileTap: onProfileTap),
          const SizedBox(width: 12),

          // --- Right Column: All Post Content ---
          _PostContentColumn(
            post: post,
            onLikeToggle: onLikeToggle,
            onCommentTap: onCommentTap,
            onShareTap: onShareTap,
            onDeletePost: onDeletePost,
          ),
        ],
      ),
    );
  }
}

// --- MODULAR SUB-WIDGETS FOR A CLEAN AND SCALABLE STRUCTURE ---

/// Displays the user's circular avatar, which is tappable to view their profile.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.post, this.onProfileTap});

  final Post post;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onProfileTap ??
          () =>
              Get.toNamed(Routes.PROFILE, arguments: {'userId': post.user.id}),
      child: CircleAvatar(
        radius: 22,
        backgroundImage:
            post.user.avatarUrl != null
                ? CachedNetworkImageProvider(post.user.avatarUrl!)
                : null,
        child:
            post.user.avatarUrl == null
                ? Text(
                  UIHelpers.getInitials(post.user.name),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
                : null,
      ),
    );
  }
}

/// The main content column containing the header, text, media, and actions.
class _PostContentColumn extends StatelessWidget {
  final Post post;
  final VoidCallback onLikeToggle;
  final VoidCallback onCommentTap;
  final VoidCallback? onShareTap;
  final Function(int postId)? onDeletePost;

  const _PostContentColumn({
    required this.post,
    required this.onLikeToggle,
    required this.onCommentTap,
    this.onShareTap,
    this.onDeletePost,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name, @handle, time, and options menu
          _PostHeader(post: post, onDeletePost: onDeletePost),
          const SizedBox(height: 4),

          // Post Text Content
          if (post.content.isNotEmpty) _PostContentText(content: post.content),

          // Post Media Attachments (Images/Videos)
          if (post.attachments != null && post.attachments!.isNotEmpty)
            Padding(
              // Add top padding only if there is text content above it
              padding: EdgeInsets.only(
                top: post.content.isNotEmpty ? 12.0 : 4.0,
              ),
              child: PostAttachmentsWidget(attachments: post.attachments!),
            ),

          // Action Toolbar: Comment, Like, Share buttons with integrated counts
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            child: _ActionToolbar(
              post: post,
              onLikeToggle: onLikeToggle,
              onCommentTap: onCommentTap,
              onShareTap: onShareTap,
            ),
          ),
        ],
      ),
    );
  }
}

/// The compact header showing user info (Name, @handle, time) and an options menu.
class _PostHeader extends StatelessWidget {
  final Post post;
  final Function(int postId)? onDeletePost;

  const _PostHeader({required this.post, this.onDeletePost});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isOwnPost = post.userId == authController.currentUser.value?.id;
    final canDelete =
        isOwnPost ||
        ['admin', 'moderator'].contains(authController.currentUser.value?.role);
    final subtleColor = Theme.of(context).textTheme.bodySmall?.color;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    post.user.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    UIHelpers.formatTimestamp(post.createdAt),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: subtleColor),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '@${post.user.username}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: subtleColor),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (canDelete)
          _MoreOptionsMenu(
            isOwnPost: isOwnPost,
            onDelete: () => onDeletePost?.call(post.id),
          ),
      ],
    );
  }
}

/// Displays the main text of the post with a "Read More" feature.
class _PostContentText extends StatelessWidget {
  final String content;

  const _PostContentText({required this.content});

  @override
  Widget build(BuildContext context) {
    return ReadMoreText(
      content,
      trimLines: 10, // X.com allows for longer previews before truncation
      trimMode: TrimMode.Line,
      colorClickableText: AppColors.primary,
      trimCollapsedText: ' Show more',
      trimExpandedText: ' Show less',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        height: 1.4,
        fontSize: 15, // A slightly larger font size for readability
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.95),
      ),
      moreStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
      lessStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }
}

/// The row of action buttons (Comment, Repost/Retweet, Like, Share).
class _ActionToolbar extends StatelessWidget {
  final Post post;
  final VoidCallback onLikeToggle;
  final VoidCallback onCommentTap;
  final VoidCallback? onShareTap;

  const _ActionToolbar({
    required this.post,
    required this.onLikeToggle,
    required this.onCommentTap,
    this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _PostActionButton(
          icon:
              post.isLiked
                  ? FontAwesomeIcons.solidHeart
                  : FontAwesomeIcons.heart,
          count: post.likesCount,
          isActive: post.isLiked,
          activeColor: AppColors.error, // A vibrant red for a liked heart
          onTap: onLikeToggle,
        ),

        _PostActionButton(
          icon: FontAwesomeIcons.comment,
          count: post.commentsCount,
          onTap: onCommentTap,
        ),

        // _PostActionButton(
        //   icon: FontAwesomeIcons.retweet,
        //   count: post.repostCount,
        //   onTap: onRepostTap,
        // ),
        _PostActionButton(
          icon: FontAwesomeIcons.shareFromSquare, // A modern 'share' icon
          onTap:
              onShareTap ??
              () => UIHelpers.showInfoSnackbar("Share feature coming soon!"),
        ),
      ],
    );
  }
}

/// A single, reusable, tappable action button with an icon and optional count.
class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final int? count;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _PostActionButton({
    required this.icon,
    required this.onTap,
    this.count,
    this.isActive = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final subtleColor = Theme.of(context).textTheme.bodySmall?.color;
    final color = isActive ? (activeColor ?? AppColors.primary) : subtleColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20), // Circular touch feedback
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Keep the row compact
          children: [
            FaIcon(icon, size: 18, color: color),
            if (count != null && count! > 0)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The three-dot options menu for editing or deleting a post.
class _MoreOptionsMenu extends StatelessWidget {
  final bool isOwnPost;
  final VoidCallback onDelete;

  const _MoreOptionsMenu({required this.isOwnPost, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz,
        color: Theme.of(context).textTheme.bodySmall?.color,
        size: 20,
      ),
      tooltip: "More options",
      onSelected: (value) {
        if (value == 'delete') {
          Get.dialog(
            AlertDialog(
              title: const Text("Delete Post?"),
              content: const Text(
                "This can’t be undone and it will be removed from your profile and the timeline.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Get.back();
                    onDelete();
                  },
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (value == 'edit') {
          UIHelpers.showInfoSnackbar("Edit feature coming soon!");
        }
      },
      itemBuilder:
          (context) => [
            if (isOwnPost)
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Edit Post'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  SizedBox(width: 12),
                  Text('Delete Post', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
    );
  }
}
