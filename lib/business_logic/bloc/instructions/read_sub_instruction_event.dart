part of 'read_sub_instruction_bloc.dart';

sealed class ReadSubInstructionEvent extends Equatable {
  const ReadSubInstructionEvent();

  @override
  List<Object> get props => [];
}

class ReadSubInstructionLoadEvent extends ReadSubInstructionEvent {
  final int id;
  final int subId;

  ReadSubInstructionLoadEvent(this.id, this.subId);
}
