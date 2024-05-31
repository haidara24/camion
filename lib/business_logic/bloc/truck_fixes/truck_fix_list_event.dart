part of 'truck_fix_list_bloc.dart';

sealed class TruckFixListEvent extends Equatable {
  const TruckFixListEvent();

  @override
  List<Object> get props => [];
}

class TruckFixListLoad extends TruckFixListEvent {
  TruckFixListLoad();
}
