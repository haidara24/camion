part of 'accept_request_for_driver_bloc.dart';

sealed class AcceptRequestForDriverEvent extends Equatable {
  const AcceptRequestForDriverEvent();

  @override
  List<Object> get props => [];
}

class AcceptRequestButtonPressedEvent extends AcceptRequestForDriverEvent {
  final int id;

  AcceptRequestButtonPressedEvent(
    this.id,
  );
}
