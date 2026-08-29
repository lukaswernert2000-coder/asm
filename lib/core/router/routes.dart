abstract final class AsmRoutes {
  static const home = '/';
  static const search = '/search';
  static const create = '/create';
  static const chats = '/chats';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';

  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const confirmEmail = '/confirm-email';
  static const onboarding = '/onboarding';

  static String category(String slug) => '/category/$slug';
  static String listing(String id) => '/listing/$id';
  static String chat(String id) => '/chat/$id';
  static String publicProfile(String id) => '/user/$id';

  static const settings = '/settings';
  static const legal = '/legal';
  static const favorites = '/favorites';
  static const myListings = '/my-listings';

  /// Nur im Debug-Build registriert, siehe `app_router.dart`.
  static const debugGallery = '/_gallery';
}
