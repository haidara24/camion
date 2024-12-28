import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/request_repository.dart';
import 'package:equatable/equatable.dart';

part 'reject_request_for_driver_event.dart';
part 'reject_request_for_driver_state.dart';

class RejectRequestForDriverBloc
    extends Bloc<RejectRequestForDriverEvent, RejectRequestForDriverState> {
  late RequestRepository requestRepository;
  RejectRequestForDriverBloc({required this.requestRepository})
      : super(RejectRequestForDriverInitial()) {
    on<RejectRequestButtonPressedEvent>((event, emit) async {
      emit(RejectRequestLoadingProgressState());
      try {
        var result = await requestRepository.rejectRequestForDriver(
          event.id,
        );

        emit(RejectRequestForDriverSuccessState(result));
      } catch (e) {
        emit(RejectRequestForDriverFailureState(e.toString()));
      }
    });
  }
}
