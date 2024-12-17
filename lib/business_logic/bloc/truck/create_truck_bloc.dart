import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/repositories/truck_repository.dart';
import 'package:equatable/equatable.dart';

part 'create_truck_event.dart';
part 'create_truck_state.dart';

class CreateTruckBloc extends Bloc<CreateTruckEvent, CreateTruckState> {
  late TruckRepository truckRepository;
  CreateTruckBloc({required this.truckRepository})
      : super(CreateTruckInitial()) {
    on<CreateTruckButtonPressed>((event, emit) async {
      emit(CreateTruckLoadingProgressState());
      try {
        var result =
            await truckRepository.createKTruck(event.truck, event.files);

        emit(CreateTruckSuccessState(result!));
      } catch (e) {
        emit(CreateTruckFailureState(e.toString()));
      }
    });

    on<CreateOwnerTruckButtonPressed>((event, emit) async {
      emit(CreateTruckLoadingProgressState());
      try {
        var result = await truckRepository.createKTruckForOwner(
            event.truck, event.files);

        emit(CreateTruckSuccessState(result!));
      } catch (e) {
        emit(CreateTruckFailureState(e.toString()));
      }
    });
  }
}
