import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'activate_shipment_event.dart';
part 'activate_shipment_state.dart';

class ActivateShipmentBloc
    extends Bloc<ActivateShipmentEvent, ActivateShipmentState> {
  late ShipmentRepository shipmentRepository;
  ActivateShipmentBloc({required this.shipmentRepository})
      : super(ActivateShipmentInitial()) {
    on<ActivateShipmentButtomPressedEvent>((event, emit) async {
      emit(ActivateShipmentLoadingProgress());
      try {
        var result =
            await shipmentRepository.activeShipmentStatus(event.shipmentId);
        if (result["status"] == 200) {
          emit(ActivateShipmentLoadedSuccess(result["details"]));
        } else {
          emit(ActivateShipmentLoadedFailed(result['details']));
        }
      } catch (e) {
        emit(ActivateShipmentLoadedFailed(e.toString()));
      }
    });
  }
}
