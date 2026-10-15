import 'package:business_repository/business_repository.dart';
import 'package:evently_vendor/app/app.dart';
import 'package:evently_vendor/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

AppState _onboarding(OnboardingStep step) => AppState(
  status: AppStatus.onboardingRequired,
  user: testUser,
  onboardingStep: step,
);

void main() {
  late AppBloc appBloc;
  late BusinessRepository businessRepository;

  setUp(() {
    appBloc = MockAppBloc();
    businessRepository = MockBusinessRepository();
    when(
      () => businessRepository.getCategories(),
    ).thenAnswer((_) async => ['Photographer']);
  });

  testWidgets('shows the profile step and signs out on confirmed back', (
    tester,
  ) async {
    when(() => appBloc.state).thenReturn(_onboarding(OnboardingStep.profile));
    await tester.pumpApp(
      const OnboardingPage(),
      appBloc: appBloc,
      businessRepository: businessRepository,
    );

    expect(find.byType(UserInformationPage), findsOneWidget);
    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign out?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Sign out'));
    await tester.pumpAndSettle();
    verify(() => appBloc.add(const AppSignOutRequested())).called(1);
  });

  testWidgets('cancelling sign out keeps the user in onboarding', (
    tester,
  ) async {
    when(() => appBloc.state).thenReturn(_onboarding(OnboardingStep.profile));
    await tester.pumpApp(const OnboardingPage(), appBloc: appBloc);

    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => appBloc.add(const AppSignOutRequested()));
    expect(find.byType(UserInformationPage), findsOneWidget);
  });

  testWidgets('lets the user go back from the business step to the profile', (
    tester,
  ) async {
    when(() => appBloc.state).thenReturn(_onboarding(OnboardingStep.business));
    await tester.pumpApp(
      const OnboardingPage(),
      appBloc: appBloc,
      businessRepository: businessRepository,
    );
    await tester.pumpAndSettle();

    expect(find.byType(BusinessDetailsPage), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(UserInformationPage), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(BusinessDetailsPage), findsOneWidget);
  });
}
