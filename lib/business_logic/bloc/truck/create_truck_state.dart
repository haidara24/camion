part of 'create_truck_bloc.dart';

sealed class CreateTruckState extends Equatable {
  const CreateTruckState();

  @override
  List<Object> get props => [];
}

final class CreateTruckInitial extends CreateTruckState {}

class CreateTruckLoadingProgressState extends CreateTruckState {}

class CreateTruckSuccessState extends CreateTruckState {
  final KTruck truck;

  CreateTruckSuccessState(this.truck);
}

class CreateTruckErrorState extends CreateTruckState {
  final String? error;
  const CreateTruckErrorState(this.error);
}

class CreateTruckFailureState extends CreateTruckState {
  final String errorMessage;

  const CreateTruckFailureState(this.errorMessage);
}
