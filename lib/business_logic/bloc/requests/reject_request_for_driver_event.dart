part of 'reject_request_for_driver_bloc.dart';

sealed class RejectRequestForDriverEvent extends Equatable {
  const RejectRequestForDriverEvent();

  @override
  List<Object> get props => [];
}

class RejectRequestButtonPressedEvent extends RejectRequestForDriverEvent {
  final int id;

  RejectRequestButtonPressedEvent(this.id);
}
