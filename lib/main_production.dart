import 'package:evently_vendor/app/app.dart';
import 'package:evently_vendor/bootstrap.dart';
import 'package:evently_vendor/firebase_options_prod.dart';

Future<void> main() async {
  await bootstrap(
    (notificationsRepository, userRepository, businessRepository) => App(
      notificationsRepository: notificationsRepository,
      userRepository: userRepository,
      businessRepository: businessRepository,
    ),
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
