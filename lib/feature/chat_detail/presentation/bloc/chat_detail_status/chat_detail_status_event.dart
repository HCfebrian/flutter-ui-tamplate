part of 'chat_detail_status_bloc.dart';

abstract class ChatDetailStatusEvent extends Equatable {
  const ChatDetailStatusEvent();
}

enum ChatStatus { online, typing, notTyping, offline }

class ChatDetailChangeStatusTypingEvent extends ChatDetailStatusEvent {
  final ChatStatus chatStatus;
  final types.Room room;
  final String myUserId;

  const ChatDetailChangeStatusTypingEvent(
      {required this.chatStatus, required this.room, required this.myUserId});

  @override
  List<Object?> get props => [
        chatStatus,
        room,
        myUserId,
      ];
}

class ChatDetailStatusStartStreamEvent extends ChatDetailStatusEvent {
  final types.Room room;
  final String myUserId;

  const ChatDetailStatusStartStreamEvent({
    required this.room,
    required this.myUserId,
  });

  @override
  List<Object?> get props => [
        room,
        myUserId,
      ];
}

class ChatDetailShowStatusEvent extends ChatDetailStatusEvent {
  final ChatStatus status;

  const ChatDetailShowStatusEvent({required this.status});

  @override
  List<Object?> get props => [status];
}
