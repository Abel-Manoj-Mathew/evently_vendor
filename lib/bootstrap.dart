import 'dart:async';
import 'dart:developer';

import 'package:authentication_client/authentication_client.dart';
import 'package:bloc/bloc.dart';
import 'package:business_repository/business_repository.dart';
import 'package:customer_repository/customer_repository.dart';
import 'package:database_client/database_client.dart';
import 'package:env/env.dart';
import 'package:evently_vendor/app/app_dependencies.dart';
import 'package:evently_vendor/app/view/config_error_app.dart';
import 'package:evently_vendor/firebase/firebase_messaging_background_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications_client/firebase_notifications_client.dart';
import 'package:flutter/widgets.dart';
import 'package:notifications_client/notifications_client.dart';
import 'package:notifications_repository/notifications_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_repository/user_repository.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    // State contents can include phone numbers and names; log types only.
    log('onChange(${bloc.runtimeType})');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

/// Fallback [NotificationsClient] when Firebase is not supported or available.
class InMemoryNotificationsClient implements NotificationsClient {
  const InMemoryNotificationsClient();

  @override
  Future<String?> fetchToken() async => null;

  @override
  Stream<String> onTokenRefresh() => const Stream.empty();

  @override
  Future<void> requestPermission() async {}
}

Future<void> bootstrap(
  FutureOr<Widget> Function(AppDependencies dependencies) builder, {
  required AppEnvironment environment,
  required FirebaseOptions firebaseOptions,
}) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();

  final AppConfig config;
  try {
    config = AppConfig.fromEnvironment(expected: environment);
  } on AppConfigException catch (error) {
    // Fail loudly instead of falling back to another environment.
    log(error.toString(), name: 'EVENTLY_CONFIG');
    runApp(ConfigErrorApp(problems: error.problems));
    return;
  }

  await Supabase.initialize(
    url: config.supabaseUrl,
    publishableKey: config.supabasePublishableKey,
  );

  NotificationsRepository notificationsRepository;

  try {
    await Firebase.initializeApp(options: firebaseOptions);

    // Background handler
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    // Foreground handler. Payloads can contain customer details, so only
    // the fact that a message arrived is logged.
    FirebaseMessaging.onMessage.listen((message) {
      log('Received a foreground message: ${message.messageId}');
    });

    // Tap handler (App opened from notification)
    await FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        log(
          'App opened from terminated state by message: ${message.messageId}',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log(
        'App opened from background state by message: ${message.messageId}',
      );
    });

    final firebaseMessaging = FirebaseMessaging.instance;
    final notificationsClient = FirebaseNotificationsClient(
      firebaseMessaging: firebaseMessaging,
    );
    notificationsRepository = NotificationsRepository(
      notificationsClient: notificationsClient,
    );
  } on Object catch (error, stackTrace) {
    log(
      'Firebase initialization error: $error',
      stackTrace: stackTrace,
    );
    notificationsRepository = const NotificationsRepository(
      notificationsClient: InMemoryNotificationsClient(),
    );
  }

  final supabaseClient = Supabase.instance.client;
  final databaseClient = DatabaseClient(supabaseClient: supabaseClient);

  runApp(
    await builder(
      AppDependencies(
        authenticationClient: AuthenticationClient(
          authClient: supabaseClient.auth,
        ),
        notificationsRepository: notificationsRepository,
        userRepository: UserRepository(databaseClient: databaseClient),
        businessRepository: BusinessRepository(databaseClient: databaseClient),
        customerRepository: CustomerRepository(databaseClient: databaseClient),
      ),
    ),
  );
}
