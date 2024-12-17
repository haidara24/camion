part of 'trip_report_bloc.dart';

sealed class TripReportEvent extends Equatable {
  const TripReportEvent();

  @override
  List<Object> get props => [];
}

class TripReportLoadEvent extends TripReportEvent {
  final int imei;
  final String startTime;
  final String endTime;

  TripReportLoadEvent(this.startTime, this.endTime, this.imei);
}
