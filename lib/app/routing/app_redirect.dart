import 'package:evently_vendor/app/bloc/app_bloc.dart';
import 'package:evently_vendor/app/routing/app_routes.dart';

/// Decides where a navigation to [location] should go for [state].
///
/// Returns `null` to allow the navigation. Every non-null result is a
/// location that this function allows for the same [state], so redirects
/// cannot loop.
///
/// While the session is being restored, protected locations are parked on
/// the splash screen with a `from` parameter so the original destination
/// (e.g. a notification deep link) is resumed once the user is ready.
String? appRedirect(AppState state, Uri location) {
  final path = location.path;
  final isSplash = path == AppRoutes.splash;
  final isLogin = _isWithin(path, AppRoutes.login);
  final isOnboarding = path == AppRoutes.onboarding;

  switch (state.status) {
    case AppStatus.initializing:
    case AppStatus.failure:
      if (isSplash) return null;
      if (isLogin || isOnboarding) return AppRoutes.splash;
      return Uri(
        path: AppRoutes.splash,
        queryParameters: {'from': location.toString()},
      ).toString();
    case AppStatus.unauthenticated:
      return isLogin ? null : AppRoutes.login;
    case AppStatus.onboardingRequired:
      return isOnboarding ? null : AppRoutes.onboarding;
    case AppStatus.ready:
      if (isSplash || isLogin || isOnboarding) {
        return _resumableLocation(location.queryParameters['from']) ??
            AppRoutes.home;
      }
      return null;
  }
}

bool _isWithin(String path, String root) =>
    path == root || path.startsWith('$root/');

/// Only resume in-app paths that a ready user may visit.
String? _resumableLocation(String? from) {
  if (from == null) return null;
  final uri = Uri.tryParse(from);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  final path = uri.path;
  if (!path.startsWith('/') ||
      path == AppRoutes.splash ||
      path == AppRoutes.onboarding ||
      _isWithin(path, AppRoutes.login)) {
    return null;
  }
  return from;
}
