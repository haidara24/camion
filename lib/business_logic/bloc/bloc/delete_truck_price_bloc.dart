import 'package:bloc/bloc.dart';
import 'package:camion/data/models/core_model.dart';
import 'package:camion/data/repositories/truck_price_repository.dart';
import 'package:equatable/equatable.dart';

part 'delete_truck_price_event.dart';
part 'delete_truck_price_state.dart';

class DeleteTruckPriceBloc
    extends Bloc<DeleteTruckPriceEvent, DeleteTruckPriceState> {
  late TruckPriceRepository truckPriceRepository;
  DeleteTruckPriceBloc({required this.truckPriceRepository})
      : super(DeleteTruckPriceInitial()) {
    on<DeleteTruckPriceButtonPressed>((event, emit) async {
      emit(DeleteTruckPriceLoadingProgressState());
      try {
        var result = await truckPriceRepository.deleteTruckPrice(
          event.truckPrice,
        );

        emit(DeleteTruckPriceSuccessState(result!));
      } catch (e) {
        emit(DeleteTruckPriceFailureState(e.toString()));
      }
    });
  }
}
