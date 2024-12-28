import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/request_repository.dart';
import 'package:equatable/equatable.dart';

part 'accept_request_for_driver_event.dart';
part 'accept_request_for_driver_state.dart';

class AcceptRequestForDriverBloc
    extends Bloc<AcceptRequestForDriverEvent, AcceptRequestForDriverState> {
  late RequestRepository requestRepository;
  AcceptRequestForDriverBloc({required this.requestRepository})
      : super(AcceptRequestForDriverInitial()) {
    on<AcceptRequestButtonPressedEvent>((event, emit) async {
      emit(AcceptRequestLoadingProgressState());
      try {
        var result = await requestRepository.acceptRequestForDriver(
          event.id,
        );

        emit(AcceptRequestForDriverSuccessState(result));
      } catch (e) {
        emit(AcceptRequestForDriverFailureState(e.toString()));
      }
    });
  }
}
