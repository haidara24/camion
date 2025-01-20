import 'package:bloc/bloc.dart';
import 'package:camion/data/models/core_model.dart';
import 'package:camion/data/repositories/truck_price_repository.dart';
import 'package:equatable/equatable.dart';

part 'create_truck_price_event.dart';
part 'create_truck_price_state.dart';

class CreateTruckPriceBloc
    extends Bloc<CreateTruckPriceEvent, CreateTruckPriceState> {
  late TruckPriceRepository truckPriceRepository;
  CreateTruckPriceBloc({required this.truckPriceRepository})
      : super(CreateTruckPriceInitial()) {
    on<CreateTruckPriceButtonPressed>((event, emit) async {
      emit(CreateTruckPriceLoadingProgressState());
      try {
        var result = await truckPriceRepository.createTruckPrice(
          event.truckPrice,
        );

        emit(CreateTruckPriceSuccessState(result!));
      } catch (e) {
        emit(CreateTruckPriceFailureState(e.toString()));
      }
    });
  }
}
