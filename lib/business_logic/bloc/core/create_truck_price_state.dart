part of 'create_truck_price_bloc.dart';

sealed class CreateTruckPriceState extends Equatable {
  const CreateTruckPriceState();

  @override
  List<Object> get props => [];
}

final class CreateTruckPriceInitial extends CreateTruckPriceState {}

class CreateTruckPriceLoadingProgressState extends CreateTruckPriceState {}

class CreateTruckPriceSuccessState extends CreateTruckPriceState {
  final TruckPrice truckPrice;

  CreateTruckPriceSuccessState(this.truckPrice);
}

class CreateTruckPriceErrorState extends CreateTruckPriceState {
  final String? error;
  const CreateTruckPriceErrorState(this.error);
}

class CreateTruckPriceFailureState extends CreateTruckPriceState {
  final String errorMessage;

  const CreateTruckPriceFailureState(this.errorMessage);
}
