import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sq_connect/app/data/models/user_model.dart';
import 'package:sq_connect/app/routes/app_routes.dart';
import 'package:sq_connect/app/ui/utils/helpers.dart';

class UserSearchTile extends StatelessWidget {
  final User user;
  const UserSearchTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: user.avatarUrl != null
            ? CachedNetworkImageProvider(user.avatarUrl!)
            : null,
        child: user.avatarUrl == null
            ? Text(UIHelpers.getInitials(user.name), style: const TextStyle(fontSize: 18))
            : null,
      ),
      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('@${user.username}', style: TextStyle(color: Colors.grey[600])),
      onTap: () => Get.toNamed(Routes.PROFILE, arguments: {'userId': user.id}),
      // You could add a "Follow" button here if you implement following functionality
    );
  }
}