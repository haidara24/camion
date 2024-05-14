import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'shipment_update_status_event.dart';
part 'shipment_update_status_state.dart';

class ShipmentUpdateStatusBloc
    extends Bloc<ShipmentUpdateStatusEvent, ShipmentUpdateStatusState> {
  late ShipmentRepository shipmentRepository;
  ShipmentUpdateStatusBloc({required this.shipmentRepository})
      : super(ShipmentUpdateStatusInitial()) {
    on<ShipmentStatusUpdateEvent>(
      (event, emit) async {
        emit(ShipmentUpdateStatusLoadingProgress());
        try {
          var data = await shipmentRepository.updateKShipmentStatus(
              event.state, event.offerId);
          if (data) {
            emit(ShipmentUpdateStatusLoadedSuccess());
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
