part of 'delete_store_bloc.dart';

sealed class DeleteStoreState extends Equatable {
  const DeleteStoreState();

  @override
  List<Object> get props => [];
}

final class DeleteStoreInitial extends DeleteStoreState {}

class DeleteStoreLoadingProgressState extends DeleteStoreState {}

class DeleteStoreSuccessState extends DeleteStoreState {
  final bool store;

  DeleteStoreSuccessState(this.store);
}

class DeleteStoreErrorState extends DeleteStoreState {
  final String? error;
  const DeleteStoreErrorState(this.error);
}

class DeleteStoreFailureState extends DeleteStoreState {
  final String errorMessage;

  const DeleteStoreFailureState(this.errorMessage);
}
