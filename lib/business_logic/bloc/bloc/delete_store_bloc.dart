import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/store_repository.dart';
import 'package:equatable/equatable.dart';

part 'delete_store_event.dart';
part 'delete_store_state.dart';

class DeleteStoreBloc extends Bloc<DeleteStoreEvent, DeleteStoreState> {
  late StoreRepository storeRepository;
  DeleteStoreBloc({required this.storeRepository})
      : super(DeleteStoreInitial()) {
    on<DeleteStoreButtonPressed>((event, emit) async {
      emit(DeleteStoreLoadingProgressState());
      try {
        var result = await storeRepository.deleteStore(
          event.store,
        );

        emit(DeleteStoreSuccessState(result!));
      } catch (e) {
        emit(DeleteStoreFailureState(e.toString()));
      }
    });
  }
}
