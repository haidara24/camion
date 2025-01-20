part of 'truck_prices_list_bloc.dart';

sealed class TruckPricesListEvent extends Equatable {
  const TruckPricesListEvent();

  @override
  List<Object> get props => [];
}

class TruckPricesListLoadEvent extends TruckPricesListEvent {}
