import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:evently_vendor/firebase/firebase_messaging_background_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications_client/firebase_notifications_client.dart';
import 'package:flutter/widgets.dart';
import 'package:notifications_repository/notifications_repository.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(
  FutureOr<Widget> Function(NotificationsRepository notificationsRepository) builder, {
  required FirebaseOptions firebaseOptions,
}) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);

  // Background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Foreground handler
  FirebaseMessaging.onMessage.listen((message) {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.data}');

    if (message.notification != null) {
      log('Message also contained a notification: ${message.notification}');
    }
  });

  // Tap handler (App opened from notification)
  await FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      log('App opened from terminated state by message: ${message.messageId}');
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    log('App opened from background state by message: ${message.messageId}');
  });

  final firebaseMessaging = FirebaseMessaging.instance;
  final notificationsClient = FirebaseNotificationsClient(
    firebaseMessaging: firebaseMessaging,
  );
  final notificationsRepository = NotificationsRepository(
    notificationsClient: notificationsClient,
  );

  runApp(await builder(notificationsRepository));
}
