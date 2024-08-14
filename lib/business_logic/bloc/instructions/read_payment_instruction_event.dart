part of 'read_payment_instruction_bloc.dart';

sealed class ReadPaymentInstructionEvent extends Equatable {
  const ReadPaymentInstructionEvent();

  @override
  List<Object> get props => [];
}

class ReadPaymentInstructionLoadEvent extends ReadPaymentInstructionEvent {
  final int id;

  ReadPaymentInstructionLoadEvent(this.id);
}
