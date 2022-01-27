part of 'chat_detail_bloc.dart';

abstract class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();

  @override
  List<Object?> get props => [];
}

class ChatDetailInitStreamEvent extends ChatDetailEvent {
  final types.Room room;

  const ChatDetailInitStreamEvent(this.room);

  @override
  List<Object?> get props => [];
}

class ChatDetailDisplayMessageEvent extends ChatDetailEvent {
  final List<types.Message> listMessage;

  const ChatDetailDisplayMessageEvent({required this.listMessage});

  @override
  List<Object?> get props => [];
}

class ChatDetailDisposeEvent extends ChatDetailEvent {
  const ChatDetailDisposeEvent();

  @override
  List<Object?> get props => [];
}

class ChatDetailDeleteEvent extends ChatDetailEvent {
  final types.Message message;
  final types.Room room;

  const ChatDetailDeleteEvent({
    required this.message,
    required this.room,
  });

  @override
  List<Object?> get props => [message];
}
