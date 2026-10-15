import 'package:authentication_client/authentication_client.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:business_repository/business_repository.dart';
import 'package:customer_repository/customer_repository.dart';
import 'package:evently_vendor/app/app.dart';
import 'package:evently_vendor/profile/profile.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notifications_repository/notifications_repository.dart';
import 'package:user_repository/user_repository.dart';

class MockAuthenticationClient extends Mock implements AuthenticationClient {}

class MockUserRepository extends Mock implements UserRepository {}

class MockBusinessRepository extends Mock implements BusinessRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

const testUser = AuthenticatedUser(id: 'user-1', phone: '+919876543210');

const readyAppState = AppState(status: AppStatus.ready, user: testUser);
