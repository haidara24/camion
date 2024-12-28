part of 'reject_request_for_driver_bloc.dart';

sealed class RejectRequestForDriverState extends Equatable {
  const RejectRequestForDriverState();

  @override
  List<Object> get props => [];
}

final class RejectRequestForDriverInitial extends RejectRequestForDriverState {}

class RejectRequestLoadingProgressState extends RejectRequestForDriverState {}

class RejectRequestForDriverSuccessState extends RejectRequestForDriverState {
  final bool result;

  RejectRequestForDriverSuccessState(this.result);
}

class RejectRequestForDriverErrorState extends RejectRequestForDriverState {
  final String? error;
  const RejectRequestForDriverErrorState(this.error);
}

class RejectRequestForDriverFailureState extends RejectRequestForDriverState {
  final String errorMessage;

  const RejectRequestForDriverFailureState(this.errorMessage);
}
