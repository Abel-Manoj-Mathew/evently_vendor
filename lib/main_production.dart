import 'package:env/env.dart';
import 'package:evently_vendor/app/app.dart';
import 'package:evently_vendor/bootstrap.dart';
import 'package:evently_vendor/firebase_options_prod.dart';

// Run with --dart-define-from-file=config/production.json
Future<void> main() async {
  await bootstrap(
    App.fromDependencies,
    environment: AppEnvironment.production,
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
