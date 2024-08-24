import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 're_active_shipment_event.dart';
part 're_active_shipment_state.dart';

class ReActiveShipmentBloc
    extends Bloc<ReActiveShipmentEvent, ReActiveShipmentState> {
  late ShipmentRepository shipmentRepository;
  ReActiveShipmentBloc({required this.shipmentRepository})
      : super(ReActiveShipmentInitial()) {
    on<ReActiveShipmentButtonPressed>((event, emit) async {
      emit(ReActiveShippmentLoadingProgressState());
      try {
        await shipmentRepository.reActiveShipment(event.shipment);

        emit(ReActiveShipmentSuccessState());
      } catch (e) {
        emit(ReActiveShipmentFailureState(e.toString()));
      }
    });
  }
}
