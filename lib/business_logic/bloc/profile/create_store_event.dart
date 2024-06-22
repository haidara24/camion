part of 'create_store_bloc.dart';

sealed class CreateStoreEvent extends Equatable {
  const CreateStoreEvent();

  @override
  List<Object> get props => [];
}

class CreateStoreButtonPressed extends CreateStoreEvent {
  final Stores stores;
  CreateStoreButtonPressed(this.stores);
}
