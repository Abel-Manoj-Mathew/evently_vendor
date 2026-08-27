import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

/// Background message handler for Firebase Cloud Messaging.
/// Must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as
  // Firestore, make sure you call `initializeApp` before using other Firebase
  // services.
  // We can't know the flavor (options) purely from background here statically
  // unless injected, but if initialized from native side it might already work.
  // For basic FCM data payload we just log it.
  log('Handling a background message: ${message.messageId}');
}
