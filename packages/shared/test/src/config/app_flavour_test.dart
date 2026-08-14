import 'package:env/env.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('AppFlavor', () {
    test('development flavor returns correct properties and envs', () {
      final appFlavor = AppFlavor.development();
      expect(appFlavor.flavor, equals(Flavor.development));
      expect(appFlavor.getEnv(Env.supabaseUrl), equals(EnvDev.supabaseUrl));
      expect(
        appFlavor.getEnv(Env.supabaseAnonKey),
        equals(EnvDev.supabaseAnonKey),
      );
    });

    test('staging flavor returns correct properties and envs', () {
      final appFlavor = AppFlavor.staging();
      expect(appFlavor.flavor, equals(Flavor.staging));
      expect(appFlavor.getEnv(Env.supabaseUrl), equals(EnvProd.supabaseUrl));
      expect(
        appFlavor.getEnv(Env.supabaseAnonKey),
        equals(EnvProd.supabaseAnonKey),
      );
    });

    test('production flavor returns correct properties and envs', () {
      final appFlavor = AppFlavor.production();
      expect(appFlavor.flavor, equals(Flavor.production));
      expect(appFlavor.getEnv(Env.supabaseUrl), equals(EnvProd.supabaseUrl));
      expect(
        appFlavor.getEnv(Env.supabaseAnonKey),
        equals(EnvProd.supabaseAnonKey),
      );
    });
  });
}
