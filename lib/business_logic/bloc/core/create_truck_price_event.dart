part of 'create_truck_price_bloc.dart';

sealed class CreateTruckPriceEvent extends Equatable {
  const CreateTruckPriceEvent();

  @override
  List<Object> get props => [];
}

class CreateTruckPriceButtonPressed extends CreateTruckPriceEvent {
  final Map<String, dynamic> truckPrice;

  CreateTruckPriceButtonPressed(
    this.truckPrice,
  );
}
