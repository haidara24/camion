part of 'owner_notifications_bloc.dart';

sealed class OwnerNotificationsState extends Equatable {
  const OwnerNotificationsState();

  @override
  List<Object> get props => [];
}

final class OwnerNotificationsInitial extends OwnerNotificationsState {}

class OwnerNotificationsLoadingProgress extends OwnerNotificationsState {}

class OwnerNotificationsLoadedSuccess extends OwnerNotificationsState {
  final List<NotificationModel> notifications;

  const OwnerNotificationsLoadedSuccess({required this.notifications});
}

class OwnerNotificationsLoadedFailed extends OwnerNotificationsState {
  final String errorText;

  const OwnerNotificationsLoadedFailed({required this.errorText});
}
