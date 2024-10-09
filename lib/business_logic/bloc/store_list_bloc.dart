import 'package:bloc/bloc.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/repositories/store_repository.dart';
import 'package:equatable/equatable.dart';

part 'store_list_event.dart';
part 'store_list_state.dart';

class StoreListBloc extends Bloc<StoreListEvent, StoreListState> {
  late StoreRepository storeRepository;
  StoreListBloc({required this.storeRepository}) : super(StoreListInitial()) {
    on<StoreListLoadEvent>((event, emit) async {
      emit(StoreListLoadingProgress());
      try {
        var stores = await storeRepository.getStoress();
        emit(StoreListLoadedSuccess(stores));
        // ignore: empty_catches
      } catch (e) {}
    });
  }
}
