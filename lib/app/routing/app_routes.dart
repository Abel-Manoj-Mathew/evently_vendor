/// Route locations used across the app.
abstract final class AppRoutes {
  /// Shown while the session is restored and when startup fails.
  static const splash = '/';

  static const login = '/login';
  static const phoneNumber = '/login/phone';
  static const verifyOtp = '/login/phone/verify';

  static const onboarding = '/onboarding';

  // Bottom-navigation tabs.
  static const home = '/home';
  static const calendar = '/calendar';
  static const insights = '/insights';
  static const profile = '/profile';

  // Full-screen routes reached from within the app.
  static const notifications = '/notifications';
  static const newBooking = '/bookings/new';
  static const services = '/services';
  static const editBusiness = '/business/edit';
  static const customerDetailsPattern = '/customers/:customerId';

  static String customerDetails(String customerId) =>
      '/customers/${Uri.encodeComponent(customerId)}';
}
