import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'shipment_update_status_event.dart';
part 'shipment_update_status_state.dart';

class DriverShipmentUpdateStatusBloc
    extends Bloc<ShipmentUpdateStatusEvent, ShipmentUpdateStatusState> {
  late ShipmentRepository shipmentRepository;
  DriverShipmentUpdateStatusBloc({required this.shipmentRepository})
      : super(ShipmentUpdateStatusInitial()) {
    on<UpdateShipmentStatusEvent>(
      (event, emit) async {
        emit(ShipmentUpdateStatusLoadingProgress());
        try {
          var data = await shipmentRepository.updateShipmentStatus(
              event.shipmentId, event.state);
          if (data) {
            emit(const ShipmentUpdateStatusLoadedSuccess());
          } else {
            emit(const ShipmentUpdateStatusLoadedFailed("خطأ"));
          }
        } catch (e) {
          emit(ShipmentUpdateStatusLoadedFailed(e.toString()));
        }
      },
    );
  }
}
