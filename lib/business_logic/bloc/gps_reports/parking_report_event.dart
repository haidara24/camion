part of 'parking_report_bloc.dart';

sealed class ParkingReportEvent extends Equatable {
  const ParkingReportEvent();

  @override
  List<Object> get props => [];
}

class ParkingReportLoadEvent extends ParkingReportEvent {
  final int imei;
  final String startTime;
  final String endTime;

  ParkingReportLoadEvent(this.startTime, this.endTime, this.imei);
}
