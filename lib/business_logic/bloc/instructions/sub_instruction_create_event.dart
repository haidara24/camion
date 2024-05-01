part of 'sub_instruction_create_bloc.dart';

sealed class SubInstructionCreateEvent extends Equatable {
  const SubInstructionCreateEvent();

  @override
  List<Object> get props => [];
}

class SubInstructionCreateButtonPressed extends SubInstructionCreateEvent {
  final int id;
  final SubShipmentInstruction instruction;

  SubInstructionCreateButtonPressed(this.instruction, this.id);
}
