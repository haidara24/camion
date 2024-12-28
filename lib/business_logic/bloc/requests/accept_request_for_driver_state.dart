part of 'accept_request_for_driver_bloc.dart';

sealed class AcceptRequestForDriverState extends Equatable {
  const AcceptRequestForDriverState();

  @override
  List<Object> get props => [];
}

final class AcceptRequestForDriverInitial extends AcceptRequestForDriverState {}

class AcceptRequestLoadingProgressState extends AcceptRequestForDriverState {}

class AcceptRequestForDriverSuccessState extends AcceptRequestForDriverState {
  final bool result;

  AcceptRequestForDriverSuccessState(this.result);
}

class AcceptRequestForDriverErrorState extends AcceptRequestForDriverState {
  final String? error;
  const AcceptRequestForDriverErrorState(this.error);
}

class AcceptRequestForDriverFailureState extends AcceptRequestForDriverState {
  final String errorMessage;

  const AcceptRequestForDriverFailureState(this.errorMessage);
}
