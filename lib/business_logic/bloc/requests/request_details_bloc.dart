import 'package:bloc/bloc.dart';
import 'package:camion/data/models/approval_request.dart';
import 'package:camion/data/repositories/request_repository.dart';
import 'package:equatable/equatable.dart';

part 'request_details_event.dart';
part 'request_details_state.dart';

class RequestDetailsBloc
    extends Bloc<RequestDetailsEvent, RequestDetailsState> {
  late RequestRepository requestRepository;
  RequestDetailsBloc({required this.requestRepository})
      : super(RequestDetailsInitial()) {
    on<RequestDetailsLoadEvent>((event, emit) async {
      emit(RequestDetailsLoadingProgress());
      try {
        var result = await requestRepository.getRequestDetails(event.id);
        if (result != null) {
          emit(RequestDetailsLoadedSuccess(result));
        } else {
          emit(RequestDetailsLoadedFailed("error"));
        }
      } catch (e) {
        emit(RequestDetailsLoadedFailed(e.toString()));
      }
    });
  }
}
