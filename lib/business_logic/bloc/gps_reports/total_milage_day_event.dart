part of 'total_milage_day_bloc.dart';

sealed class TotalMilageDayEvent extends Equatable {
  const TotalMilageDayEvent();

  @override
  List<Object> get props => [];
}

class TotalMilageDayLoadEvent extends TotalMilageDayEvent {
  final int imei;
  final String startTime;
  final String endTime;

  TotalMilageDayLoadEvent(this.startTime, this.endTime, this.imei);
}
