part of 'over_speed_bloc.dart';

sealed class OverSpeedState extends Equatable {
  const OverSpeedState();

  @override
  List<Object> get props => [];
}

final class OverSpeedInitial extends OverSpeedState {}

class OverSpeedLoadingProgress extends OverSpeedState {}

class OverSpeedLoadedSuccess extends OverSpeedState {
  final List<Map<String, dynamic>> result;

  const OverSpeedLoadedSuccess(this.result);
}

class OverSpeedLoadedFailed extends OverSpeedState {
  final String error;

  const OverSpeedLoadedFailed(this.error);
}
