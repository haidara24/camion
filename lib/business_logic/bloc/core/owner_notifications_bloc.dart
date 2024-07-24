import 'package:bloc/bloc.dart';
import 'package:camion/data/models/notification_model.dart';
import 'package:camion/data/repositories/notification_repository.dart';
import 'package:equatable/equatable.dart';

part 'owner_notifications_event.dart';
part 'owner_notifications_state.dart';

class OwnerNotificationsBloc
    extends Bloc<OwnerNotificationsEvent, OwnerNotificationsState> {
  late NotificationRepository notificationRepository;
  OwnerNotificationsBloc({required this.notificationRepository})
      : super(OwnerNotificationsInitial()) {
    on<OwnerNotificationsLoadEvent>((event, emit) async {
      emit(OwnerNotificationsLoadingProgress());
      try {
        var data =
            await notificationRepository.getDriverNotificationsForOwner();
        emit(OwnerNotificationsLoadedSuccess(notifications: data));
      } catch (e) {
        emit(OwnerNotificationsLoadedFailed(errorText: e.toString()));
      }
    });
  }
}
