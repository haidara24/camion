part of 'truck_prices_list_bloc.dart';

sealed class TruckPricesListState extends Equatable {
  const TruckPricesListState();

  @override
  List<Object> get props => [];
}

final class TruckPricesListInitial extends TruckPricesListState {}

class TruckPricesListLoadingProgress extends TruckPricesListState {}

class TruckPricesListLoadedSuccess extends TruckPricesListState {
  final List<TruckPrice> prices;

  const TruckPricesListLoadedSuccess(this.prices);
}

class TruckPricesListLoadedFailed extends TruckPricesListState {
  final String error;

  const TruckPricesListLoadedFailed(this.error);
}
