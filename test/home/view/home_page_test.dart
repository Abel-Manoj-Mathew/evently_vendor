import 'package:evently_vendor/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomePage', () {
    testWidgets('renders top bar, schedule, bookings, workspace and bottom nav',
        (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.text("Today's Schedule"), findsOneWidget);
      expect(find.text('No events scheduled today.'), findsOneWidget);
      expect(find.text('Upcoming Bookings'), findsOneWidget);
      expect(find.text('No upcoming bookings.'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
      expect(find.text('Complete Your Workspace'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
      expect(find.text('Business Created'), findsOneWidget);
      expect(find.text('Add Your First Service'), findsOneWidget);
      expect(find.text('Upload Business Logo'), findsOneWidget);
      expect(find.text('Add Business Location'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('tapping navigation items switches tabs', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      expect(find.text('Calendar Screen'), findsOneWidget);

      await tester.tap(find.text('Services'));
      await tester.pumpAndSettle();

      expect(find.text('Services Screen'), findsOneWidget);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Profile Screen'), findsOneWidget);
    });

    test('route returns MaterialPageRoute', () {
      final route = HomePage.route();
      expect(route, isA<MaterialPageRoute<void>>());
    });
  });
}
