import 'package:bloc/bloc.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/repositories/truck_repository.dart';
import 'package:equatable/equatable.dart';

part 'create_truck_fix_event.dart';
part 'create_truck_fix_state.dart';

class CreateTruckFixBloc
    extends Bloc<CreateTruckFixEvent, CreateTruckFixState> {
  late TruckRepository truckRepository;
  CreateTruckFixBloc({required this.truckRepository})
      : super(CreateTruckFixInitial()) {
    on<CreateTruckFixButtonPressed>((event, emit) async {
      emit(CreateTruckFixLoadingProgress());
      try {
        var result = await truckRepository.createTruckExpense(event.fix);
        if (result) {
          emit(CreateTruckFixLoadedSuccess(result));
        } else {
          emit(CreateTruckFixLoadedFailed("errorstring"));
        }
      } catch (e) {
        emit(CreateTruckFixLoadedFailed(e.toString()));
      }
    });
  }
}
