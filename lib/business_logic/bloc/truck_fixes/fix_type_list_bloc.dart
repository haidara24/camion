import 'package:bloc/bloc.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/repositories/truck_repository.dart';
import 'package:equatable/equatable.dart';

part 'fix_type_list_event.dart';
part 'fix_type_list_state.dart';

class FixTypeListBloc extends Bloc<FixTypeListEvent, FixTypeListState> {
  late TruckRepository truckRepository;
  FixTypeListBloc({required this.truckRepository})
      : super(FixTypeListInitial()) {
    on<FixTypeListLoad>((event, emit) async {
      emit(FixTypeListLoadingProgress());
      try {
        var fixes = await truckRepository.getExpenseTypes();
        emit(FixTypeListLoadedSuccess(fixes));
      } catch (e) {
        emit(FixTypeListLoadedFailed(e.toString()));
      }
    });
  }
}
