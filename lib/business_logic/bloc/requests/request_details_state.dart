part of 'request_details_bloc.dart';

sealed class RequestDetailsState extends Equatable {
  const RequestDetailsState();

  @override
  List<Object> get props => [];
}

final class RequestDetailsInitial extends RequestDetailsState {}

class RequestDetailsLoadingProgress extends RequestDetailsState {}

class RequestDetailsLoadedSuccess extends RequestDetailsState {
  final ApprovalRequest request;

  const RequestDetailsLoadedSuccess(this.request);
}

class RequestDetailsLoadedFailed extends RequestDetailsState {
  final String errortext;

  const RequestDetailsLoadedFailed(this.errortext);
}
