part of 'create_truck_fix_bloc.dart';

sealed class CreateTruckFixState extends Equatable {
  const CreateTruckFixState();

  @override
  List<Object> get props => [];
}

final class CreateTruckFixInitial extends CreateTruckFixState {}

class CreateTruckFixLoadingProgress extends CreateTruckFixState {}

class CreateTruckFixLoadedSuccess extends CreateTruckFixState {
  final bool fix;

  const CreateTruckFixLoadedSuccess(this.fix);
}

class CreateTruckFixLoadedFailed extends CreateTruckFixState {
  final String errorstring;

  CreateTruckFixLoadedFailed(this.errorstring);
}
