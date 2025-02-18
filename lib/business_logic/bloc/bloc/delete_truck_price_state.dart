part of 'delete_truck_price_bloc.dart';

sealed class DeleteTruckPriceState extends Equatable {
  const DeleteTruckPriceState();

  @override
  List<Object> get props => [];
}

final class DeleteTruckPriceInitial extends DeleteTruckPriceState {}

class DeleteTruckPriceLoadingProgressState extends DeleteTruckPriceState {}

class DeleteTruckPriceSuccessState extends DeleteTruckPriceState {
  final bool truckPrice;

  DeleteTruckPriceSuccessState(this.truckPrice);
}

class DeleteTruckPriceErrorState extends DeleteTruckPriceState {
  final String? error;
  const DeleteTruckPriceErrorState(this.error);
}

class DeleteTruckPriceFailureState extends DeleteTruckPriceState {
  final String errorMessage;

  const DeleteTruckPriceFailureState(this.errorMessage);
}
