part of 'delete_store_bloc.dart';

sealed class DeleteStoreEvent extends Equatable {
  const DeleteStoreEvent();

  @override
  List<Object> get props => [];
}

class DeleteStoreButtonPressed extends DeleteStoreEvent {
  final int store;

  DeleteStoreButtonPressed(
    this.store,
  );
}
