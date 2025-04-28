import 'package:bloc/bloc.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/repositories/profile_repository.dart';
import 'package:camion/data/repositories/store_repository.dart';
import 'package:equatable/equatable.dart';

part 'create_store_event.dart';
part 'create_store_state.dart';

class CreateStoreBloc extends Bloc<CreateStoreEvent, CreateStoreState> {
  late StoreRepository storeRepository;
  CreateStoreBloc({required this.storeRepository})
      : super(CreateStoreInitial()) {
    on<CreateStoreButtonPressed>((event, emit) async {
      emit(CreateStoreLoadingProgress());
      try {
        var result = await storeRepository.createStore(event.stores);
        if (result != null) {
          emit(CreateStoreLoadedSuccess(result));
        } else {
          emit(CreateStoreLoadedFailed("errorstring"));
        }
      } catch (e) {
        emit(CreateStoreLoadedFailed(e.toString()));
      }
    });
  }
}
