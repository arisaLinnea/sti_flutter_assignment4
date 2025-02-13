import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:parking_user/repositories/notification_repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc
    extends HydratedBloc<NotificationEvent, NotificationState> {
  final NotificationRepository notRepository;

  NotificationBloc({required this.notRepository})
      : super(NotificationState(scheduledIds: {})) {
    on<NotificationEvent>((event, emit) async {
      if (event is ScheduleNotification) {
        await _handleScheduleToState(event, emit);
      } else if (event is CancelNotification) {
        await _handleCancelState(event, emit);
      } else if (event is UpdateNotificationEvent) {
        await _handleUpdateState(event, emit);
      }
    });
  }

  Future<void> _handleScheduleToState(
      ScheduleNotification event, Emitter<NotificationState> emit) async {
    int notificationId = Random().nextInt(1000);

    await notRepository.scheduleNotification(
        id: notificationId,
        title: event.title,
        content: event.content,
        deliveryTime: event.deliveryTime,
        parkingId: event.id);

    final newState = Map<String, int>.from(state.scheduledIds);
    newState[event.id] = notificationId;
    emit(NotificationState(scheduledIds: newState));
  }

  Future<void> _handleCancelState(
      CancelNotification event, Emitter<NotificationState> emit) async {
    String id = event.id;
    final notificationId = state.scheduledIds[id];
    if (notificationId != null) {
      await notRepository.cancelScheduledNotificaion(notificationId);
      final newState = Map<String, int>.from(state.scheduledIds);
      newState.remove(id);
      emit(NotificationState(scheduledIds: newState));
    }
  }

  Future<void> _handleUpdateState(
      UpdateNotificationEvent event, Emitter<NotificationState> emit) async {
    // final newState = Map<String, int>.from(state.scheduledIds);
    // newState.update(event.newTime.toString(), (value) => value);
    // emit(NotificationState(scheduledIds: newState));
  }

  @override
  NotificationState? fromJson(Map<String, dynamic> json) {
    if (json['scheduledIds'] == null) {
      return const NotificationState(scheduledIds: {});
    } else {
      return NotificationState(scheduledIds: json['scheduledIds']);
    }
  }

  @override
  Map<String, dynamic>? toJson(NotificationState state) {
    return {'scheduledIds': state.scheduledIds};
  }
}
