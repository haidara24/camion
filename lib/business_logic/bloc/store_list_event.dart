part of 'store_list_bloc.dart';

sealed class StoreListEvent extends Equatable {
  const StoreListEvent();

  @override
  List<Object> get props => [];
}

class StoreListLoadEvent extends StoreListEvent {}
