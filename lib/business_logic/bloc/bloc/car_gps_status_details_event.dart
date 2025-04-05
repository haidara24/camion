part of 'car_gps_status_details_bloc.dart';

sealed class CarGpsStatusDetailsEvent extends Equatable {
  const CarGpsStatusDetailsEvent();

  @override
  List<Object> get props => [];
}

class CarGpsStatusDetailsButtonPressed extends CarGpsStatusDetailsEvent {
  final String imei;
  CarGpsStatusDetailsButtonPressed(
    this.imei,
  );
}
