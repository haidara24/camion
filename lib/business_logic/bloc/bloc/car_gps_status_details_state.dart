part of 'car_gps_status_details_bloc.dart';

sealed class CarGpsStatusDetailsState extends Equatable {
  const CarGpsStatusDetailsState();

  @override
  List<Object> get props => [];
}

final class CarGpsStatusDetailsInitial extends CarGpsStatusDetailsState {}

class CarGpsStatusDetailsLoadingProgress extends CarGpsStatusDetailsState {}

class CarGpsStatusDetailsLoadedSuccess extends CarGpsStatusDetailsState {
  final dynamic data;

  const CarGpsStatusDetailsLoadedSuccess(this.data);
}

class CarGpsStatusDetailsLoadedFailed extends CarGpsStatusDetailsState {
  final String errortext;

  const CarGpsStatusDetailsLoadedFailed(this.errortext);
}
