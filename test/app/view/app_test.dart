// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:evently_vendor/app/app.dart';
import 'package:evently_vendor/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    testWidgets('renders LoginPage', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(App());
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
