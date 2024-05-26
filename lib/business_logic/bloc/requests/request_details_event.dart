part of 'request_details_bloc.dart';

sealed class RequestDetailsEvent extends Equatable {
  const RequestDetailsEvent();

  @override
  List<Object> get props => [];
}

class RequestDetailsLoadEvent extends RequestDetailsEvent {
  final int id;

  const RequestDetailsLoadEvent(this.id);
}
