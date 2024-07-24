part of 'create_truck_bloc.dart';

sealed class CreateTruckEvent extends Equatable {
  const CreateTruckEvent();

  @override
  List<Object> get props => [];
}

class CreateTruckButtonPressed extends CreateTruckEvent {
  final KTruck truck;
  final List<File> files;

  CreateTruckButtonPressed(this.truck, this.files);
}
