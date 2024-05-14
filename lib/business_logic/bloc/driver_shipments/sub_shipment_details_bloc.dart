import 'package:bloc/bloc.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'sub_shipment_details_event.dart';
part 'sub_shipment_details_state.dart';

class SubShipmentDetailsBloc
    extends Bloc<SubShipmentDetailsEvent, SubShipmentDetailsState> {
  late ShipmentRepository shipmentRepository;
  SubShipmentDetailsBloc({required this.shipmentRepository})
      : super(SubShipmentDetailsInitial()) {
    on<SubShipmentDetailsLoadEvent>((event, emit) async {
      emit(SubShipmentDetailsLoadingProgress());
      try {
        var result = await shipmentRepository.getSubShipment(event.id);
        if (result != null) {
          emit(SubShipmentDetailsLoadedSuccess(result));
        } else {
          emit(SubShipmentDetailsLoadedFailed("error"));
        }
      } catch (e) {
        emit(SubShipmentDetailsLoadedFailed(e.toString()));
      }
    });
  }
}
