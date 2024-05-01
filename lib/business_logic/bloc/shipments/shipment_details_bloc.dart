import 'package:bloc/bloc.dart';
import 'package:camion/data/models/shipment_model.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'shipment_details_event.dart';
part 'shipment_details_state.dart';

class ShipmentDetailsBloc
    extends Bloc<ShipmentDetailsEvent, ShipmentDetailsState> {
  late ShippmentRerository shippmentRerository;
  ShipmentDetailsBloc({required this.shippmentRerository})
      : super(ShipmentDetailsInitial()) {
    on<ShipmentDetailsLoadEvent>((event, emit) async {
      emit(ShipmentDetailsLoadingProgress());
      try {
        var result = await shippmentRerository.getShipment(event.id);
        if (result != null) {
          emit(ShipmentDetailsLoadedSuccess(result));
        } else {
          emit(ShipmentDetailsLoadedFailed("error"));
        }
      } catch (e) {
        emit(ShipmentDetailsLoadedFailed(e.toString()));
      }
    });
  }
}
