import 'package:bloc/bloc.dart';
import 'package:camion/data/models/approval_request.dart';
import 'package:camion/data/repositories/request_repository.dart';
import 'package:equatable/equatable.dart';

part 'driver_requests_list_event.dart';
part 'driver_requests_list_state.dart';

class DriverRequestsListBloc
    extends Bloc<DriverRequestsListEvent, DriverRequestsListState> {
  late RequestRepository requestRepository;
  DriverRequestsListBloc({required this.requestRepository})
      : super(DriverRequestsListInitial()) {
    on<DriverRequestsListLoadEvent>((event, emit) async {
      emit(DriverRequestsListLoadingProgress());
      try {
        var result = await requestRepository.getApprovalRequests(event.driverId);

        emit(DriverRequestsListLoadedSuccess(result));
      } catch (e) {
        emit(DriverRequestsListLoadedFailed(e.toString()));
      }
    });
  }
}
