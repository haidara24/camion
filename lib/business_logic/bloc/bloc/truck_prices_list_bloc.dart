import 'package:bloc/bloc.dart';
import 'package:camion/data/models/core_model.dart';
import 'package:camion/data/repositories/truck_price_repository.dart';
import 'package:equatable/equatable.dart';

part 'truck_prices_list_event.dart';
part 'truck_prices_list_state.dart';

class TruckPricesListBloc
    extends Bloc<TruckPricesListEvent, TruckPricesListState> {
  late TruckPriceRepository truckPriceRepository;
  TruckPricesListBloc({required this.truckPriceRepository})
      : super(TruckPricesListInitial()) {
    on<TruckPricesListLoadEvent>((event, emit) async {
      emit(TruckPricesListLoadingProgress());
      try {
        var result = await truckPriceRepository.getPrices();
        emit(TruckPricesListLoadedSuccess(result));
      } catch (e) {
        emit(TruckPricesListLoadedFailed(e.toString()));
      }
    });
  }
}
