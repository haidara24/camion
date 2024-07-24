part of 'owner_notifications_bloc.dart';

sealed class OwnerNotificationsEvent extends Equatable {
  const OwnerNotificationsEvent();

  @override
  List<Object> get props => [];
}

class OwnerNotificationsLoadEvent extends OwnerNotificationsEvent {}
