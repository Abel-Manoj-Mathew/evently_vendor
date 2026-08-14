import 'package:env/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Env', () {
    test('EnvDev has valid static fields', () {
      expect(EnvDev.supabaseUrl, isA<String>());
      expect(EnvDev.supabaseAnonKey, isA<String>());
    });

    test('EnvProd has valid static fields', () {
      expect(EnvProd.supabaseUrl, isA<String>());
      expect(EnvProd.supabaseAnonKey, isA<String>());
    });
  });
}
