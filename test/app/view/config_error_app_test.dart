import 'package:env/env.dart';
import 'package:evently_vendor/app/view/config_error_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lists configuration problems instead of starting the app', (
    tester,
  ) async {
    late AppConfigException exception;
    try {
      AppConfig.parse(
        expected: AppEnvironment.production,
        values: const {
          'EVENTLY_ENV': 'development',
          'SUPABASE_URL': 'https://abcd.supabase.co',
          'SUPABASE_PUBLISHABLE_KEY': 'sb_secret_abc',
        },
      );
    } on AppConfigException catch (error) {
      exception = error;
    }

    await tester.pumpWidget(ConfigErrorApp(problems: exception.problems));

    expect(find.text('This build is not configured'), findsOneWidget);
    expect(
      find.textContaining('configuration file is for development'),
      findsOneWidget,
    );
    expect(find.textContaining('secret/service-role key'), findsOneWidget);
  });
}
