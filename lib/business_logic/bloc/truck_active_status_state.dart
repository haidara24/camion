part of 'truck_active_status_bloc.dart';

sealed class TruckActiveStatusState extends Equatable {
  const TruckActiveStatusState();

  @override
  List<Object> get props => [];
}

final class TruckActiveStatusInitial extends TruckActiveStatusState {}

class TruckActiveStatusLoadingProgress extends TruckActiveStatusState {}

class TruckActiveStatusLoadedSuccess extends TruckActiveStatusState {
  final bool status;

  const TruckActiveStatusLoadedSuccess(this.status);
}

class TruckActiveStatusLoadedFailed extends TruckActiveStatusState {
  final String errortext;

  const TruckActiveStatusLoadedFailed(this.errortext);
}
