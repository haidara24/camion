part of 'parking_report_bloc.dart';

sealed class ParkingReportState extends Equatable {
  const ParkingReportState();

  @override
  List<Object> get props => [];
}

final class ParkingReportInitial extends ParkingReportState {}

class ParkingReportLoadingProgress extends ParkingReportState {}

class ParkingReportLoadedSuccess extends ParkingReportState {
  final List<Map<String, dynamic>> result;

  const ParkingReportLoadedSuccess(this.result);
}

class ParkingReportLoadedFailed extends ParkingReportState {
  final String error;

  const ParkingReportLoadedFailed(this.error);
}
