part of 'trip_report_bloc.dart';

sealed class TripReportState extends Equatable {
  const TripReportState();

  @override
  List<Object> get props => [];
}

final class TripReportInitial extends TripReportState {}

class TripReportLoadingProgress extends TripReportState {}

class TripReportLoadedSuccess extends TripReportState {
  final List<Map<String, dynamic>> result;

  const TripReportLoadedSuccess(this.result);
}

class TripReportLoadedFailed extends TripReportState {
  final String error;

  const TripReportLoadedFailed(this.error);
}
