part of 'driver_requests_list_bloc.dart';

sealed class DriverRequestsListState extends Equatable {
  const DriverRequestsListState();

  @override
  List<Object> get props => [];
}

final class DriverRequestsListInitial extends DriverRequestsListState {}

class DriverRequestsListLoadingProgress extends DriverRequestsListState {}

class DriverRequestsListLoadedSuccess extends DriverRequestsListState {
  final List<ApprovalRequest> requests;

  const DriverRequestsListLoadedSuccess(this.requests);
}

class DriverRequestsListLoadedFailed extends DriverRequestsListState {
  final String errortext;

  const DriverRequestsListLoadedFailed(this.errortext);
}
