import 'dart:convert';

import 'package:env/env.dart';
import 'package:test/test.dart';

Map<String, String> _values({
  String environment = 'development',
  String url = 'https://abcd.supabase.co',
  String key = 'sb_publishable_test',
}) => {
  'EVENTLY_ENV': environment,
  'SUPABASE_URL': url,
  'SUPABASE_PUBLISHABLE_KEY': key,
};

String _jwtWithRole(String role) {
  String encode(Object json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${encode({'alg': 'HS256'})}.${encode({'role': role})}.signature';
}

Matcher _throwsProblem(String fragment) => throwsA(
  isA<AppConfigException>().having(
    (e) => e.problems.join('\n'),
    'problems',
    contains(fragment),
  ),
);

void main() {
  group('AppEnvironment.tryParse', () {
    test('parses known names and rejects unknown ones', () {
      expect(AppEnvironment.tryParse('production'), AppEnvironment.production);
      expect(AppEnvironment.tryParse('prod'), isNull);
    });
  });

  group('AppConfig.parse', () {
    test('returns config for valid values', () {
      final config = AppConfig.parse(
        expected: AppEnvironment.development,
        values: _values(),
      );
      expect(config.environment, AppEnvironment.development);
      expect(config.supabaseUrl, 'https://abcd.supabase.co');
      expect(config.supabasePublishableKey, 'sb_publishable_test');
    });

    test('fails when nothing was defined', () {
      expect(
        () => AppConfig.parse(
          expected: AppEnvironment.production,
          values: const {},
        ),
        throwsA(
          isA<AppConfigException>().having(
            (e) => e.problems,
            'problems',
            hasLength(3),
          ),
        ),
      );
    });

    test('rejects a development file in a production build', () {
      expect(
        () => AppConfig.parse(
          expected: AppEnvironment.production,
          values: _values(),
        ),
        _throwsProblem('configuration file is for development'),
      );
    });

    test('rejects unknown environment names', () {
      expect(
        () => AppConfig.parse(
          expected: AppEnvironment.development,
          values: _values(environment: 'dev'),
        ),
        _throwsProblem('is not valid'),
      );
    });

    test('rejects placeholder values copied from example files', () {
      expect(
        () => AppConfig.parse(
          expected: AppEnvironment.development,
          values: _values(url: 'https://<project-ref>.supabase.co'),
        ),
        _throwsProblem('placeholder'),
      );
      expect(
        () => AppConfig.parse(
          expected: AppEnvironment.development,
          values: _values(key: '<publishable-key>'),
        ),
        _throwsProblem('placeholder'),
      );
    });

    test('rejects invalid URLs', () {
      expect(
        () => AppConfig.parse(
          expected: AppEnvironment.development,
          values: _values(url: 'not a url'),
        ),
        _throwsProblem('not a valid URL'),
      );
    });

    test('allows http only in development', () {
      expect(
        AppConfig.parse(
          expected: AppEnvironment.development,
          values: _values(url: 'http://10.0.2.2:54321'),
        ).supabaseUrl,
        'http://10.0.2.2:54321',
      );
      expect(
        () => AppConfig.parse(
          expected: AppEnvironment.production,
          values: _values(
            environment: 'production',
            url: 'http://abcd.supabase.co',
          ),
        ),
        _throwsProblem('must use https'),
      );
    });

    test('rejects new-style secret keys', () {
      expect(
        () => AppConfig.parse(
          expected: AppEnvironment.development,
          values: _values(key: 'sb_secret_abc'),
        ),
        _throwsProblem('secret/service-role'),
      );
    });

    test('rejects legacy service_role JWTs but accepts anon JWTs', () {
      expect(
        () => AppConfig.parse(
          expected: AppEnvironment.development,
          values: _values(key: _jwtWithRole('service_role')),
        ),
        _throwsProblem('secret/service-role'),
      );
      expect(
        AppConfig.parse(
          expected: AppEnvironment.development,
          values: _values(key: _jwtWithRole('anon')),
        ).environment,
        AppEnvironment.development,
      );
    });

    test('exception message lists problems and points to docs', () {
      const exception = AppConfigException(['a', 'b']);
      expect(exception.toString(), contains('- a\n- b'));
      expect(exception.toString(), contains('docs/'));
    });
  });

  group('AppConfig.fromEnvironment', () {
    test('fails when the build has no defines', () {
      expect(
        () => AppConfig.fromEnvironment(expected: AppEnvironment.development),
        throwsA(isA<AppConfigException>()),
      );
    });
  });
}
