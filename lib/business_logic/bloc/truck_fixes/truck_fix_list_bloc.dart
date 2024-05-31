import 'package:bloc/bloc.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/repositories/truck_repository.dart';
import 'package:equatable/equatable.dart';

part 'truck_fix_list_event.dart';
part 'truck_fix_list_state.dart';

class TruckFixListBloc extends Bloc<TruckFixListEvent, TruckFixListState> {
  late TruckRepository truckRepository;
  TruckFixListBloc({required this.truckRepository})
      : super(TruckFixListInitial()) {
    on<TruckFixListLoad>((event, emit) async {
      emit(TruckFixListLoadingProgress());
      try {
        var fixes = await truckRepository.getTruckExpenses();
        emit(TruckFixListLoadedSuccess(fixes));
      } catch (e) {
        emit(TruckFixListLoadedFailed(e.toString()));
      }
    });
  }
}
