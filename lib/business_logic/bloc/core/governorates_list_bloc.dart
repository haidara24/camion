import 'package:bloc/bloc.dart';
import 'package:camion/data/models/core_model.dart';
import 'package:camion/data/repositories/core_repository.dart';
import 'package:equatable/equatable.dart';

part 'governorates_list_event.dart';
part 'governorates_list_state.dart';

class GovernoratesListBloc
    extends Bloc<GovernoratesListEvent, GovernoratesListState> {
  late CoreRepository coreRepository;
  GovernoratesListBloc({required this.coreRepository})
      : super(GovernoratesListInitial()) {
    on<GovernoratesListLoadEvent>((event, emit) async {
      emit(GovernoratesListLoadingProgress());
      try {
        var result = await coreRepository.getGovernorates();
        emit(GovernoratesListLoadedSuccess(result));
      } catch (e) {
        emit(GovernoratesListLoadedFailed(e.toString()));
      }
    });
  }
}
