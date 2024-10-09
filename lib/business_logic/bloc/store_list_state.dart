part of 'store_list_bloc.dart';

sealed class StoreListState extends Equatable {
  const StoreListState();

  @override
  List<Object> get props => [];
}

final class StoreListInitial extends StoreListState {}

class StoreListLoadingProgress extends StoreListState {}

class StoreListLoadedSuccess extends StoreListState {
  final List<Stores> stores;

  const StoreListLoadedSuccess(this.stores);
}

class StoreListLoadedFailed extends StoreListState {
  final String errortext;

  const StoreListLoadedFailed(this.errortext);
}
