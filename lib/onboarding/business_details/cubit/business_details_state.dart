import 'package:equatable/equatable.dart';

enum BusinessDetailsStatus {
  initial,
  loadingCategories,
  loading,
  success,
  failure,
}

class BusinessDetailsState extends Equatable {
  const BusinessDetailsState({
    this.status = BusinessDetailsStatus.initial,
    this.categories = const [],
  });

  final BusinessDetailsStatus status;
  final List<String> categories;

  BusinessDetailsState copyWith({
    BusinessDetailsStatus? status,
    List<String>? categories,
  }) {
    return BusinessDetailsState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object> get props => [status, categories];
}
