part of 'update_truck_price_bloc.dart';

sealed class UpdateTruckPriceEvent extends Equatable {
  const UpdateTruckPriceEvent();

  @override
  List<Object> get props => [];
}

class UpdateTruckPriceButtonPressed extends UpdateTruckPriceEvent {
  final Map<String, dynamic> truckPrice;

  UpdateTruckPriceButtonPressed(
    this.truckPrice,
  );
}
