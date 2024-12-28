import 'package:bloc/bloc.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'owner_active_shipments_event.dart';
part 'owner_active_shipments_state.dart';

class OwnerActiveShipmentsBloc
    extends Bloc<OwnerActiveShipmentsEvent, OwnerActiveShipmentsState> {
  late ShipmentRepository shipmentRepository;
  OwnerActiveShipmentsBloc({required this.shipmentRepository})
      : super(OwnerActiveShipmentsInitial()) {
    on<OwnerActiveShipmentsLoadEvent>((event, emit) async {
      emit(OwnerActiveShipmentsLoadingProgress());
      try {
        var result =
            await shipmentRepository.getDriverRunningShipmentListForOwner("R");
        emit(OwnerActiveShipmentsLoadedSuccess(result));
      } catch (e) {
        emit(OwnerActiveShipmentsLoadedFailed(e.toString()));
      }
    });

    on<OwnerActiveShipmentsRefreash>((event, emit) async {
      OwnerActiveShipmentsLoadedSuccess currentState =
          state as OwnerActiveShipmentsLoadedSuccess;
      emit(OwnerActiveShipmentsLoadingProgress());
      try {
        emit(OwnerActiveShipmentsLoadedSuccess(currentState.shipments));
      } catch (e) {
        emit(OwnerActiveShipmentsLoadedFailed(e.toString()));
      }
    });
  }
}
