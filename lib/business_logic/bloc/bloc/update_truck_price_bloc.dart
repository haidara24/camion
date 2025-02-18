import 'package:bloc/bloc.dart';
import 'package:camion/data/models/core_model.dart';
import 'package:camion/data/repositories/truck_price_repository.dart';
import 'package:equatable/equatable.dart';

part 'update_truck_price_event.dart';
part 'update_truck_price_state.dart';

class UpdateTruckPriceBloc
    extends Bloc<UpdateTruckPriceEvent, UpdateTruckPriceState> {
  late TruckPriceRepository truckPriceRepository;
  UpdateTruckPriceBloc({required this.truckPriceRepository})
      : super(UpdateTruckPriceInitial()) {
    on<UpdateTruckPriceButtonPressed>((event, emit) async {
      emit(UpdateTruckPriceLoadingProgressState());
      try {
        var result = await truckPriceRepository.updateTruckPrice(
          event.truckPrice,
        );

        emit(UpdateTruckPriceSuccessState(result!));
      } catch (e) {
        emit(UpdateTruckPriceFailureState(e.toString()));
      }
    });
  }
}
