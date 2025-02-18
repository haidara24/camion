part of 'delete_truck_price_bloc.dart';

sealed class DeleteTruckPriceEvent extends Equatable {
  const DeleteTruckPriceEvent();

  @override
  List<Object> get props => [];
}

class DeleteTruckPriceButtonPressed extends DeleteTruckPriceEvent {
  final int truckPrice;

  DeleteTruckPriceButtonPressed(
    this.truckPrice,
  );
}
