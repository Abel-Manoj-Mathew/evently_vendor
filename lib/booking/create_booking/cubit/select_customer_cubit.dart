import 'package:bloc/bloc.dart';
import 'package:customer_repository/customer_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

enum SelectCustomerStatus { loading, success, noBusiness, failure }

final class SelectCustomerState extends Equatable {
  const SelectCustomerState({
    this.status = SelectCustomerStatus.loading,
    this.customers = const [],
    this.query = '',
  });

  final SelectCustomerStatus status;
  final List<Customer> customers;
  final String query;

  /// Customers matching [query] by name or phone digits.
  List<Customer> get visibleCustomers {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return customers;
    final digits = text.replaceAll(RegExp(r'\D'), '');
    return customers.where((customer) {
      if (customer.name.toLowerCase().contains(text)) return true;
      final phone = customer.phone?.replaceAll(RegExp(r'\D'), '') ?? '';
      return digits.isNotEmpty && phone.contains(digits);
    }).toList();
  }

  SelectCustomerState copyWith({
    SelectCustomerStatus? status,
    List<Customer>? customers,
    String? query,
  }) {
    return SelectCustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [status, customers, query];
}

/// Loads the business's customers for the first booking step.
class SelectCustomerCubit extends Cubit<SelectCustomerState> {
  SelectCustomerCubit({
    required this._customerRepository,
    required this._ownerId,
  }) : super(const SelectCustomerState());

  final CustomerRepository _customerRepository;
  final String _ownerId;

  Future<void> load() async {
    emit(state.copyWith(status: SelectCustomerStatus.loading));
    try {
      final businessId = await _customerRepository.getBusinessIdForUser(
        _ownerId,
      );
      if (businessId == null) {
        emit(state.copyWith(status: SelectCustomerStatus.noBusiness));
        return;
      }
      final customers = await _customerRepository.getCustomers(
        businessId: businessId,
      );
      emit(
        state.copyWith(
          status: SelectCustomerStatus.success,
          customers: customers,
        ),
      );
    } on Object catch (error, stackTrace) {
      logE('Loading customers failed', error: error, stackTrace: stackTrace);
      emit(state.copyWith(status: SelectCustomerStatus.failure));
    }
  }

  void queryChanged(String query) => emit(state.copyWith(query: query));

  /// Shows a newly created or reused customer without a reload.
  void customerAdded(Customer customer) {
    final others = state.customers.where((c) => c.id != customer.id);
    emit(state.copyWith(customers: [customer, ...others]));
  }
}
