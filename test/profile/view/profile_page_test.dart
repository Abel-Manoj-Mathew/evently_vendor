import 'package:bloc_test/bloc_test.dart';
import 'package:business_repository/business_repository.dart';
import 'package:evently_vendor/app/app.dart';
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
  late AppBloc appBloc;
  late ProfileCubit profileCubit;

  setUp(() {
    appBloc = MockAppBloc();
    when(() => appBloc.state).thenReturn(readyAppState);
    profileCubit = MockProfileCubit();
    when(() => profileCubit.state).thenReturn(
      const ProfileState(status: ProfileStatus.success, profile: _profile),
    );
  });

  Future<void> pumpProfile(WidgetTester tester) {
    final router = GoRouter(
      initialLocation: AppRoutes.profile,
      routes: [
        GoRoute(
          path: AppRoutes.profile,
          builder: (_, _) => BlocProvider.value(
            value: profileCubit,
            child: const ProfilePage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.services,
          builder: (_, _) => const Text('services'),
        ),
        GoRoute(
          path: AppRoutes.editBusiness,
          builder: (_, _) => const Text('edit business'),
        ),
      ],
    );
    return tester.pumpRouterApp(router, appBloc: appBloc);
  }

  testWidgets('shows stored business details without fake settings', (
    tester,
  ) async {
    await pumpProfile(tester);
    expect(find.text('Lens & Light Studio'), findsNWidgets(2));
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Notifications'), findsNothing);
  });

  testWidgets('opens services from the profile', (tester) async {
    await pumpProfile(tester);
    await tester.ensureVisible(find.text('Services'));
    await tester.tap(find.text('Services'));
    await tester.pumpAndSettle();
    expect(find.text('services'), findsOneWidget);
  });

  testWidgets('confirms before signing out through AppBloc', (tester) async {
    await pumpProfile(tester);
    await tester.ensureVisible(find.text('Log Out'));
    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log Out').last);
    await tester.pumpAndSettle();
    verify(() => appBloc.add(const AppSignOutRequested())).called(1);
  });

  testWidgets('reports a failed sign-out', (tester) async {
    whenListen(
      appBloc,
      Stream.value(
        const AppState(
          status: AppStatus.ready,
          user: testUser,
          signOutFailed: true,
        ),
      ),
      initialState: readyAppState,
    );
    await pumpProfile(tester);
    await tester.pump();
    expect(find.text("Couldn't log out. Please try again."), findsOneWidget);
  });
}
