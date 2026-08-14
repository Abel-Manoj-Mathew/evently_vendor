// Not required for test files
// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:env/env.dart';

void main() {
  group('Env', () {
    test('can be instantiated', () {
      expect(Env(), isNotNull);
    });
  });
}
