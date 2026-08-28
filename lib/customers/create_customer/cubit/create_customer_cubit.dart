import 'package:bloc/bloc.dart';
import 'package:business_repository/business_repository.dart';
import 'package:evently_vendor/customers/create_customer/cubit/create_customer_state.dart';

class CreateCustomerCubit extends Cubit<CreateCustomerState> {
  CreateCustomerCubit({
    required this.businessRepository,
  }) : super(const CreateCustomerState());

  final BusinessRepository businessRepository;

  void nameChanged(String value) {
    emit(state.copyWith(name: value, status: CreateCustomerStatus.initial));
  }

  void phoneChanged(String value) {
    emit(state.copyWith(phone: value, status: CreateCustomerStatus.initial));
  }

  void emailChanged(String value) {
    emit(state.copyWith(email: value, status: CreateCustomerStatus.initial));
  }

  void notesChanged(String value) {
    emit(state.copyWith(notes: value, status: CreateCustomerStatus.initial));
  }

  void countryCodeChanged(String value) {
    emit(state.copyWith(countryCode: value, status: CreateCustomerStatus.initial));
  }

  Future<void> submit() async {
    if (state.name.trim().isEmpty || state.phone.trim().isEmpty) return;

    emit(state.copyWith(status: CreateCustomerStatus.loading));
    try {
      final businessId = await businessRepository.getDefaultBusinessId();
      if (businessId == null) {
        throw Exception('No business found for the user.');
      }

      await businessRepository.createCustomer(
        businessId: businessId,
        name: state.name.trim(),
        phone: '${state.countryCode}${state.phone.trim()}',
        email: state.email.trim(),
        notes: state.notes.trim(),
      );

      emit(state.copyWith(status: CreateCustomerStatus.success));
    } catch (e, stackTrace) {
      print('Error creating customer: $e\n$stackTrace');
      emit(state.copyWith(status: CreateCustomerStatus.failure));
    }
  }
}
