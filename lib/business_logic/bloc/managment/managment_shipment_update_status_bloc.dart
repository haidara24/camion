import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'managment_shipment_update_status_event.dart';
part 'managment_shipment_update_status_state.dart';

class ManagmentShipmentUpdateStatusBloc extends Bloc<
    ManagmentShipmentUpdateStatusEvent, ManagmentShipmentUpdateStatusState> {
  late ShipmentRepository shipmentRepository;

  ManagmentShipmentUpdateStatusBloc({required this.shipmentRepository})
      : super(ManagmentShipmentUpdateStatusInitial()) {
    on<UpdateStatusManagmentShipmentEvent>(
      (event, emit) async {
        emit(ManagmentShipmentUpdateStatusLoadingProgress());
        try {
          // var data = await shipmentRepository.updateKShipmentStatus(
          //     event.state, event.offerId);
          // if (data) {
          //   emit(ManagmentShipmentUpdateStatusLoadedSuccess());
          // } else {
          //   emit(const ManagmentShipmentUpdateStatusLoadedFailed("خطأ"));
          // }
        } catch (e) {
          emit(ManagmentShipmentUpdateStatusLoadedFailed(e.toString()));
        }
      },
    );
  }
}
