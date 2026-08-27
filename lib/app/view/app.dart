import 'package:app_ui/app_ui.dart';
import 'package:evently_vendor/auth/login/login.dart';
import 'package:evently_vendor/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notifications_repository/notifications_repository.dart';

class App extends StatelessWidget {
  const App({
    required this._notificationsRepository,
    super.key,
  });

  final NotificationsRepository _notificationsRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _notificationsRepository,
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
