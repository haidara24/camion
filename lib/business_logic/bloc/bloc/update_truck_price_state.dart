part of 'update_truck_price_bloc.dart';

sealed class UpdateTruckPriceState extends Equatable {
  const UpdateTruckPriceState();

  @override
  List<Object> get props => [];
}

final class UpdateTruckPriceInitial extends UpdateTruckPriceState {}

class UpdateTruckPriceLoadingProgressState extends UpdateTruckPriceState {}

class UpdateTruckPriceSuccessState extends UpdateTruckPriceState {
  final bool truckPrice;

  UpdateTruckPriceSuccessState(this.truckPrice);
}

class UpdateTruckPriceErrorState extends UpdateTruckPriceState {
  final String? error;
  const UpdateTruckPriceErrorState(this.error);
}

class UpdateTruckPriceFailureState extends UpdateTruckPriceState {
  final String errorMessage;

  const UpdateTruckPriceFailureState(this.errorMessage);
}
