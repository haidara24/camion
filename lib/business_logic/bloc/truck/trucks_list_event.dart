part of 'trucks_list_bloc.dart';

sealed class TrucksListEvent extends Equatable {
  const TrucksListEvent();

  @override
  List<Object> get props => [];
}

class NearestTrucksListLoadEvent extends TrucksListEvent {
  final List<int> truckType;
  final String location;
  final String pol;
  final String pod;

  NearestTrucksListLoadEvent(this.truckType, this.location, this.pol, this.pod);
}

class TrucksListLoadEvent extends TrucksListEvent {
  final List<int> truckType;

  TrucksListLoadEvent(this.truckType);
}

class TrucksListSearchEvent extends TrucksListEvent {
  final String truckType;

  TrucksListSearchEvent(this.truckType);
}
