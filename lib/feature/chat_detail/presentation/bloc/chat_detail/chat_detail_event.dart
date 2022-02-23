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

class ChatSendMessageEvent extends ChatDetailEvent {
  final types.PartialText message;
  final types.Room room;

  const ChatSendMessageEvent({required this.message, required this.room});

  @override
  List<Object?> get props => [message];
}

class ChatMarkAsReadEvent extends ChatDetailEvent {
  final types.Message message;
  final types.Room room;

  const ChatMarkAsReadEvent({
    required this.message,
    required this.room,
  });

  @override
  List<Object?> get props => [message];
}

class ChatDetailNextPageEvent extends ChatDetailEvent {}

class ChatDetailSendImageEvent extends ChatDetailEvent {
  final String filePath;
  final types.Room room;
  final String fileName;

  const ChatDetailSendImageEvent({
    required this.filePath,
    required this.room,
    required this.fileName,
  });

  @override
  List<Object?> get props => [filePath, room];
}
