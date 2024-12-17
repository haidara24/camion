part of 'over_speed_bloc.dart';

sealed class OverSpeedEvent extends Equatable {
  const OverSpeedEvent();

  @override
  List<Object> get props => [];
}

class OverSpeedLoadEvent extends OverSpeedEvent {
  final int imei;
  final String startTime;
  final String endTime;

  OverSpeedLoadEvent(this.startTime, this.endTime, this.imei);
}
