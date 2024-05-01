part of 'read_sub_instruction_bloc.dart';

sealed class ReadSubInstructionState extends Equatable {
  const ReadSubInstructionState();

  @override
  List<Object> get props => [];
}

final class ReadSubInstructionInitial extends ReadSubInstructionState {}

class ReadSubInstructionLoadingProgress extends ReadSubInstructionState {}

class ReadSubInstructionLoadedSuccess extends ReadSubInstructionState {
  final SubShipmentInstruction instruction;

  const ReadSubInstructionLoadedSuccess(this.instruction);
}

class ReadSubInstructionLoadedFailed extends ReadSubInstructionState {
  final String errortext;

  const ReadSubInstructionLoadedFailed(this.errortext);
}
