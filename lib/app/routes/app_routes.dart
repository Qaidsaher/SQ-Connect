// app_routes.dart

abstract class Routes {
  static const SPLASH = '/splash'; // New route
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home'; // Main screen with BottomNav
  static const SEARCH = '/search';
  static const POST_DETAIL = '/post-detail'; // Requires postId
  static const CREATE_POST = '/create-post';
  static const PROFILE =
      '/profile'; // Can take userId as param for other profiles
  static const EDIT_PROFILE = '/edit-profile';
  static const CONVERSATIONS = '/conversations';
  static const CHAT = '/chat'; // Requires userId of other person
}
