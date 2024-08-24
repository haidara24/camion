import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'complete_sub_shipment_event.dart';
part 'complete_sub_shipment_state.dart';

class CompleteSubShipmentBloc
    extends Bloc<CompleteSubShipmentEvent, CompleteSubShipmentState> {
  late ShipmentRepository shipmentRepository;
  CompleteSubShipmentBloc({required this.shipmentRepository})
      : super(CompleteSubShipmentInitial()) {
    on<CompleteSubShipmentButtonPressed>((event, emit) async {
      emit(CompleteSubShipmentLoadingProgress());
      try {
        await shipmentRepository.completeSubShipment(event.shipment);

        emit(CompleteSubShipmentLoadedSuccess());
      } catch (e) {
        emit(CompleteSubShipmentLoadedFailed(e.toString()));
      }
    });
  }
}
