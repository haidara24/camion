import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'cancel_shipment_event.dart';
part 'cancel_shipment_state.dart';

class CancelShipmentBloc
    extends Bloc<CancelShipmentEvent, CancelShipmentState> {
  late ShipmentRepository shipmentRepository;
  CancelShipmentBloc({required this.shipmentRepository})
      : super(CancelShipmentInitial()) {
    on<CancelShipmentButtonPressed>((event, emit) async {
      emit(ShippmentLoadingProgressState());
      try {
        await shipmentRepository.cancelShipment(event.shipment);

        emit(CancelShipmentSuccessState());
      } catch (e) {
        emit(CancelShipmentFailureState(e.toString()));
      }
    });
  }
}
