part of 'trucks_list_bloc.dart';

sealed class TrucksListEvent extends Equatable {
  const TrucksListEvent();

  @override
  List<Object> get props => [];
}

class TrucksListLoadEvent extends TrucksListEvent {
  final List<int> truckType;

  TrucksListLoadEvent(this.truckType);
}

class TrucksListSearchEvent extends TrucksListEvent {
  final String truckType;

  TrucksListSearchEvent(this.truckType);
}
