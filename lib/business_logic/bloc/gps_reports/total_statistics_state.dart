part of 'total_statistics_bloc.dart';

sealed class TotalStatisticsState extends Equatable {
  const TotalStatisticsState();

  @override
  List<Object> get props => [];
}

final class TotalStatisticsInitial extends TotalStatisticsState {}

class TotalStatisticsLoadingProgress extends TotalStatisticsState {}

class TotalStatisticsLoadedSuccess extends TotalStatisticsState {
  final Map<String, dynamic> result;

  const TotalStatisticsLoadedSuccess(this.result);
}

class TotalStatisticsLoadedFailed extends TotalStatisticsState {
  final String error;

  const TotalStatisticsLoadedFailed(this.error);
}
