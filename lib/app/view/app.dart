import 'package:app_ui/app_ui.dart';
import 'package:authentication_client/authentication_client.dart';
import 'package:business_repository/business_repository.dart';
import 'package:customer_repository/customer_repository.dart';
import 'package:evently_vendor/app/app_dependencies.dart';
import 'package:evently_vendor/app/bloc/app_bloc.dart';
import 'package:evently_vendor/app/routing/app_router.dart';
import 'package:evently_vendor/app/routing/app_routes.dart';
import 'package:evently_vendor/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:notifications_repository/notifications_repository.dart';
import 'package:user_repository/user_repository.dart';

class App extends StatelessWidget {
  const App({
    required this._authenticationClient,
    required this._notificationsRepository,
    required this._userRepository,
    required this._businessRepository,
    required this._customerRepository,
    super.key,
  });

  /// Creates the app from the dependencies built in `bootstrap`.
  factory App.fromDependencies(AppDependencies dependencies) => App(
    authenticationClient: dependencies.authenticationClient,
    notificationsRepository: dependencies.notificationsRepository,
    userRepository: dependencies.userRepository,
    businessRepository: dependencies.businessRepository,
    customerRepository: dependencies.customerRepository,
  );

  final AuthenticationClient _authenticationClient;
  final NotificationsRepository _notificationsRepository;
  final UserRepository _userRepository;
  final BusinessRepository _businessRepository;
  final CustomerRepository _customerRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authenticationClient),
        RepositoryProvider.value(value: _notificationsRepository),
        RepositoryProvider.value(value: _userRepository),
        RepositoryProvider.value(value: _businessRepository),
        RepositoryProvider.value(value: _customerRepository),
      ],
      child: BlocProvider(
        create: (_) => AppBloc(
          authenticationClient: _authenticationClient,
          userRepository: _userRepository,
          businessRepository: _businessRepository,
        )..add(const AppStarted()),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key, this.initialLocation = AppRoutes.splash});

  /// Overridable for tests.
  final String initialLocation;

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final GoRouter _router = createAppRouter(
    appBloc: context.read<AppBloc>(),
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: const AppTheme().theme,
      // Screens still hard-code light colours, so a dark theme would render
      // a mix of both. Dark mode is deferred until the screens use theme
      // tokens.
      themeMode: ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
