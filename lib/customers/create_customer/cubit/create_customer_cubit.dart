import 'package:bloc/bloc.dart';
import 'package:customer_repository/customer_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

part 'create_customer_state.dart';

/// Validates and saves a new customer.
///
/// Phone numbers are optional and may be shared. When the phone matches
/// existing customers the user is warned and chooses to reuse one of them
/// or to create a new customer anyway; records are never merged silently.
class CreateCustomerCubit extends Cubit<CreateCustomerState> {
  CreateCustomerCubit({
    required this._customerRepository,
    required this._ownerId,
  }) : super(const CreateCustomerState());

  final CustomerRepository _customerRepository;
  final String _ownerId;
  String? _businessId;

  void nameChanged(String value) => _edit(state.copyWith(name: value));

  void phoneChanged(String value) =>
      _edit(state.copyWith(phone: value, duplicatesAcknowledged: false));

  void emailChanged(String value) => _edit(state.copyWith(email: value));

  void notesChanged(String value) => _edit(state.copyWith(notes: value));

  void _edit(CreateCustomerState next) {
    if (state.isBusy) return;
    emit(next.copyWith(status: CreateCustomerStatus.editing));
  }

  /// Validates, checks for possible duplicates and saves.
  Future<void> submit() async {
    if (state.isBusy) return;
    if (!state.isValid) {
      emit(
        state.copyWith(
          status: CreateCustomerStatus.editing,
          showValidation: true,
        ),
      );
      return;
    }
    emit(
      state.copyWith(status: CreateCustomerStatus.saving, showValidation: true),
    );
    try {
      final businessId = await _resolveBusinessId();
      if (businessId == null) {
        emit(_failure(CreateCustomerFailure.noBusiness));
        return;
      }
      if (state.phone.trim().isNotEmpty && !state.duplicatesAcknowledged) {
        final duplicates = await _customerRepository.findPotentialDuplicates(
          businessId: businessId,
          phone: state.phone,
        );
        if (duplicates.isNotEmpty) {
          emit(
            state.copyWith(
              status: CreateCustomerStatus.duplicateWarning,
              duplicates: duplicates,
            ),
          );
          return;
        }
      }
      await _create(businessId);
    } on Object catch (error, stackTrace) {
      logE('Saving customer failed', error: error, stackTrace: stackTrace);
      emit(_failure(CreateCustomerFailure.unknown));
    }
  }

  /// Saves the customer even though its phone matches existing customers.
  Future<void> createAnyway() async {
    if (state.status != CreateCustomerStatus.duplicateWarning) return;
    emit(
      state.copyWith(
        status: CreateCustomerStatus.editing,
        duplicatesAcknowledged: true,
      ),
    );
    await submit();
  }

  /// Returns to editing after the duplicate warning was dismissed.
  void dismissDuplicateWarning() {
    if (state.status != CreateCustomerStatus.duplicateWarning) return;
    emit(state.copyWith(status: CreateCustomerStatus.editing));
  }

  Future<void> _create(String businessId) async {
    try {
      final customer = await _customerRepository.createCustomer(
        businessId: businessId,
        name: state.name,
        phone: state.phone,
        email: state.email,
        notes: state.notes,
      );
      emit(
        state.copyWith(
          status: CreateCustomerStatus.success,
          createdCustomer: customer,
        ),
      );
    } on CustomerPhoneAlreadyExistsException {
      emit(_failure(CreateCustomerFailure.phoneAlreadyUsed));
    }
  }

  Future<String?> _resolveBusinessId() async =>
      _businessId ??= await _customerRepository.getBusinessIdForUser(
        _ownerId,
      );

  CreateCustomerState _failure(CreateCustomerFailure failure) =>
      state.copyWith(status: CreateCustomerStatus.failure, failure: failure);
}
