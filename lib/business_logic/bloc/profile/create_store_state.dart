part of 'create_store_bloc.dart';

sealed class CreateStoreState extends Equatable {
  const CreateStoreState();
  
  @override
  List<Object> get props => [];
}

final class CreateStoreInitial extends CreateStoreState {}

class CreateStoreLoadingProgress extends CreateStoreState {}

class CreateStoreLoadedSuccess extends CreateStoreState {
  final Stores store;

  const CreateStoreLoadedSuccess(this.store);
}

class CreateStoreLoadedFailed extends CreateStoreState {
  final String errorstring;

  CreateStoreLoadedFailed(this.errorstring);
}
