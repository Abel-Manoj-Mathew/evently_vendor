import 'dart:async';
import 'package:app_ui/app_ui.dart';
import 'package:business_repository/business_repository.dart';
import 'package:evently_vendor/auth/login/login.dart';
import 'package:evently_vendor/home/home.dart';
import 'package:evently_vendor/l10n/l10n.dart';
import 'package:evently_vendor/onboarding/user_information/user_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notifications_repository/notifications_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final StreamSubscription<AuthState> _authStateSubscription;
  bool _isAuthenticated = false;
  bool _isLoading = true;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkInitialAuth();
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        _handleAuthStateChange(data.session);
      }
    });
  }

  Future<void> _checkInitialAuth() async {
    final session = Supabase.instance.client.auth.currentSession;
    await _handleAuthStateChange(session);
  }

  Future<void> _handleAuthStateChange(Session? session) async {
    if (session == null) {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isAuthenticated = true;
        _isLoading = true;
      });
    }

    try {
      final userRepository = context.read<UserRepository>();
      final hasProfile = await userRepository.profileExists(session.user.id);
      
      if (mounted) {
        setState(() {
          _hasProfile = hasProfile;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('AuthWrapper Error checking profile: $e');
      print(stackTrace);
      if (mounted) {
        setState(() {
          _hasProfile = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF4040),
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      return const LoginPage();
    }

    return _hasProfile ? const HomePage() : const UserInformationPage();
  }
}

