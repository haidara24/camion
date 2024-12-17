part of 'total_milage_day_bloc.dart';

sealed class TotalMilageDayState extends Equatable {
  const TotalMilageDayState();

  @override
  List<Object> get props => [];
}

final class TotalMilageDayInitial extends TotalMilageDayState {}

class TotalMilageDayLoadingProgress extends TotalMilageDayState {}

class TotalMilageDayLoadedSuccess extends TotalMilageDayState {
  final List<Map<String, dynamic>> result;

  const TotalMilageDayLoadedSuccess(this.result);
}

class TotalMilageDayLoadedFailed extends TotalMilageDayState {
  final String error;

  const TotalMilageDayLoadedFailed(this.error);
}
