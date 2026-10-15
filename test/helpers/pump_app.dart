import 'package:authentication_client/authentication_client.dart';
import 'package:business_repository/business_repository.dart';
import 'package:customer_repository/customer_repository.dart';
import 'package:evently_vendor/app/app.dart';
import 'package:evently_vendor/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

import 'mocks.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] as the home of a [MaterialApp] with the app's
  /// repositories and an [AppBloc], using mocks for anything not supplied.
  Future<void> pumpApp(
    Widget widget, {
    AppBloc? appBloc,
    AuthenticationClient? authenticationClient,
    UserRepository? userRepository,
    BusinessRepository? businessRepository,
    CustomerRepository? customerRepository,
  }) {
    usePhoneViewport();
    return pumpWidget(
      _withProviders(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: widget,
        ),
        appBloc: appBloc,
        authenticationClient: authenticationClient,
        userRepository: userRepository,
        businessRepository: businessRepository,
        customerRepository: customerRepository,
      ),
    );
  }

  /// Like [pumpApp], but hosts the screens in [router] so navigation can be
  /// observed.
  Future<void> pumpRouterApp(
    GoRouter router, {
    AppBloc? appBloc,
    AuthenticationClient? authenticationClient,
    UserRepository? userRepository,
    BusinessRepository? businessRepository,
    CustomerRepository? customerRepository,
  }) {
    usePhoneViewport();
    addTearDown(router.dispose);
    return pumpWidget(
      _withProviders(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
        appBloc: appBloc,
        authenticationClient: authenticationClient,
        userRepository: userRepository,
        businessRepository: businessRepository,
        customerRepository: customerRepository,
      ),
    );
  }

  void usePhoneViewport({Size size = const Size(375, 812)}) {
    view
      ..physicalSize = size
      ..devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);
  }
}

Widget _withProviders(
  Widget child, {
  AppBloc? appBloc,
  AuthenticationClient? authenticationClient,
  UserRepository? userRepository,
  BusinessRepository? businessRepository,
  CustomerRepository? customerRepository,
}) {
  final bloc = appBloc ?? MockAppBloc();
  if (appBloc == null) {
    when(() => bloc.state).thenReturn(readyAppState);
  }
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(
        value: authenticationClient ?? MockAuthenticationClient(),
      ),
      RepositoryProvider.value(value: userRepository ?? MockUserRepository()),
      RepositoryProvider.value(
        value: businessRepository ?? MockBusinessRepository(),
      ),
      RepositoryProvider.value(
        value: customerRepository ?? MockCustomerRepository(),
      ),
    ],
    child: BlocProvider.value(value: bloc, child: child),
  );
}
