import 'package:app_ui/app_ui.dart';
import 'package:business_repository/business_repository.dart';
import 'package:evently_vendor/auth/login/login.dart';
import 'package:evently_vendor/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notifications_repository/notifications_repository.dart';
import 'package:user_repository/user_repository.dart';

class App extends StatelessWidget {
  const App({
    required this._notificationsRepository,
    required this._userRepository,
    required this._businessRepository,
    super.key,
  });

  final NotificationsRepository _notificationsRepository;
  final UserRepository _userRepository;
  final BusinessRepository _businessRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _notificationsRepository),
        RepositoryProvider.value(value: _userRepository),
        RepositoryProvider.value(value: _businessRepository),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: const AppTheme().theme,
        darkTheme: const AppDarkTheme().theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LoginPage(),
      ),
    );
  }
}
