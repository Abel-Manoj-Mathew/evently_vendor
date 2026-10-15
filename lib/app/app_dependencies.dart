import 'package:authentication_client/authentication_client.dart';
import 'package:business_repository/business_repository.dart';
import 'package:customer_repository/customer_repository.dart';
import 'package:notifications_repository/notifications_repository.dart';
import 'package:user_repository/user_repository.dart';

/// Dependencies created during `bootstrap` and handed to the app widget.
class AppDependencies {
  const AppDependencies({
    required this.authenticationClient,
    required this.notificationsRepository,
    required this.userRepository,
    required this.businessRepository,
    required this.customerRepository,
  });

  final AuthenticationClient authenticationClient;
  final NotificationsRepository notificationsRepository;
  final UserRepository userRepository;
  final BusinessRepository businessRepository;
  final CustomerRepository customerRepository;
}
