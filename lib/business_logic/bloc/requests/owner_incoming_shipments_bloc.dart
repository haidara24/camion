import 'package:bloc/bloc.dart';
import 'package:camion/data/models/approval_request.dart';
import 'package:camion/data/repositories/request_repository.dart';
import 'package:equatable/equatable.dart';

part 'owner_incoming_shipments_event.dart';
part 'owner_incoming_shipments_state.dart';

class OwnerIncomingShipmentsBloc
    extends Bloc<OwnerIncomingShipmentsEvent, OwnerIncomingShipmentsState> {
  late RequestRepository requestRepository;
  OwnerIncomingShipmentsBloc({required this.requestRepository})
      : super(OwnerIncomingShipmentsInitial()) {
    on<OwnerIncomingShipmentsLoadEvent>((event, emit) async {
      emit(OwnerIncomingShipmentsLoadingProgress());
      try {
        var result = await requestRepository.getApprovalRequestsForOwner();
        emit(OwnerIncomingShipmentsLoadedSuccess(result));
      } catch (e) {
        emit(OwnerIncomingShipmentsLoadedFailed(e.toString()));
      }
    });
  }
}
