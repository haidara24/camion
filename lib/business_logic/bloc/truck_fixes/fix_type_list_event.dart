part of 'fix_type_list_bloc.dart';

sealed class FixTypeListEvent extends Equatable {
  const FixTypeListEvent();

  @override
  List<Object> get props => [];
}

class FixTypeListLoad extends FixTypeListEvent {

}