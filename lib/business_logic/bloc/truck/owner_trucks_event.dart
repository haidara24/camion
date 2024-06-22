part of 'owner_trucks_bloc.dart';

sealed class OwnerTrucksEvent extends Equatable {
  const OwnerTrucksEvent();

  @override
  List<Object> get props => [];
}

class OwnerTrucksLoadEvent extends OwnerTrucksEvent {}
