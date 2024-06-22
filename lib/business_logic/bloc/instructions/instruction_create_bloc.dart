import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camion/data/models/instruction_model.dart';
import 'package:camion/data/repositories/instruction_repository.dart';
import 'package:equatable/equatable.dart';

part 'instruction_create_event.dart';
part 'instruction_create_state.dart';

class InstructionCreateBloc
    extends Bloc<InstructionCreateEvent, InstructionCreateState> {
  late InstructionRepository instructionRepository;
  InstructionCreateBloc({required this.instructionRepository})
      : super(InstructionCreateInitial()) {
    on<InstructionCreateButtonPressed>((event, emit) async {
      emit(InstructionLoadingProgressState());
      try {
        var result = await instructionRepository.createShipmentInstruction(
            event.instruction, event.files);

        emit(InstructionCreateSuccessState(result!));
      } catch (e) {
        emit(InstructionCreateFailureState(e.toString()));
      }
    });
  }
}
