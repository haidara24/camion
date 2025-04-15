part of 'update_owner_trucks_locations_bloc.dart';

sealed class UpdateOwnerTrucksLocationsEvent extends Equatable {
  const UpdateOwnerTrucksLocationsEvent();

  @override
  List<Object> get props => [];
}

class UpdateOwnerTrucksLocationsLoadEvent
    extends UpdateOwnerTrucksLocationsEvent {}
