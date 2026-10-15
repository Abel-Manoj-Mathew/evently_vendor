import 'package:env/env.dart';
import 'package:evently_vendor/app/app.dart';
import 'package:evently_vendor/bootstrap.dart';
import 'package:evently_vendor/firebase_options_stg.dart';

// Run with --dart-define-from-file=config/staging.json
Future<void> main() async {
  await bootstrap(
    App.fromDependencies,
    environment: AppEnvironment.staging,
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
