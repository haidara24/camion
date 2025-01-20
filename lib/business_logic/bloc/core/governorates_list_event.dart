part of 'governorates_list_bloc.dart';

sealed class GovernoratesListEvent extends Equatable {
  const GovernoratesListEvent();

  @override
  List<Object> get props => [];
}

class GovernoratesListLoadEvent extends GovernoratesListEvent {}
