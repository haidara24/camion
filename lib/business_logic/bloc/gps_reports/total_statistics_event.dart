part of 'total_statistics_bloc.dart';

sealed class TotalStatisticsEvent extends Equatable {
  const TotalStatisticsEvent();

  @override
  List<Object> get props => [];
}

class TotalStatisticsLoadEvent extends TotalStatisticsEvent {
  final int imei;
  final String startTime;
  final String endTime;

  TotalStatisticsLoadEvent(this.startTime, this.endTime, this.imei);
}
