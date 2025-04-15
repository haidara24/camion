part of 'get_owner_trucks_with_gps_locations_bloc.dart';

sealed class GetOwnerTrucksWithGpsLocationsEvent extends Equatable {
  const GetOwnerTrucksWithGpsLocationsEvent();

  @override
  List<Object> get props => [];
}

class GetOwnerTrucksWithGpsLocationsLoadEvent
    extends GetOwnerTrucksWithGpsLocationsEvent {}
