import 'package:business_repository/business_repository.dart';
import 'package:evently_vendor/app/app.dart';
import 'package:evently_vendor/home/home.dart';
import 'package:evently_vendor/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

const _profile = VendorProfile(
  businessName: 'Lens & Light Studio',
  category: 'Photographer',
  location: 'Trivandrum',
  phone: '+919876543210',
  email: 'No email provided',
);

void main() {
  late ProfileCubit profileCubit;

  setUp(() {
    profileCubit = MockProfileCubit();
    when(() => profileCubit.state).thenReturn(
      const ProfileState(status: ProfileStatus.success, profile: _profile),
    );
  });

  // HomePage reads the ProfileCubit that AppShell provides for the whole
  // shell; the original tests failed because nothing provided it.
  Widget withProfile(Widget child) =>
      BlocProvider.value(value: profileCubit, child: child);

  testWidgets('renders business header, booking sections and checklist', (
    tester,
  ) async {
    await tester.pumpApp(withProfile(const HomePage()));

    expect(find.text('Lens & Light Studio'), findsOneWidget);
    expect(find.text('Photographer'), findsOneWidget);
    expect(find.text("Today's Schedule"), findsOneWidget);
    expect(find.text('Upcoming Bookings'), findsOneWidget);
    expect(find.text('Bookings are coming soon'), findsNWidgets(2));
    expect(find.text('Complete Your Workspace'), findsOneWidget);
    expect(find.text('Business Created'), findsOneWidget);
    expect(find.text('Add Your First Service'), findsOneWidget);
    expect(find.text('Upload Business Logo'), findsOneWidget);
    expect(find.text('Add Business Location'), findsOneWidget);
    expect(find.text('New Booking'), findsOneWidget);
  });

  testWidgets('does not show a fabricated progress percentage', (
    tester,
  ) async {
    await tester.pumpApp(withProfile(const HomePage()));
    expect(find.textContaining('%'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('hides the notification badge when nothing is unread', (
    tester,
  ) async {
    await tester.pumpApp(withProfile(const HomePage()));
    final badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isFalse);
  });

  testWidgets('shows a fallback title when the profile fails to load', (
    tester,
  ) async {
    when(
      () => profileCubit.state,
    ).thenReturn(const ProfileState(status: ProfileStatus.failure));
    await tester.pumpApp(withProfile(const HomePage()));
    expect(find.text("Couldn't load business details"), findsOneWidget);
  });

  testWidgets('New Booking and the bell open their screens', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => withProfile(const HomePage()),
        ),
        GoRoute(
          path: AppRoutes.newBooking,
          builder: (_, _) => const Text('new booking'),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          builder: (_, _) => const Text('notifications'),
        ),
      ],
    );
    await tester.pumpRouterApp(router);

    await tester.tap(find.text('New Booking'));
    await tester.pumpAndSettle();
    expect(find.text('new booking'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('notifications'), findsOneWidget);
  });
}
