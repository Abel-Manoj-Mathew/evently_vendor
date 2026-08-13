import 'package:evently_vendor/app/app.dart';
import 'package:evently_vendor/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
