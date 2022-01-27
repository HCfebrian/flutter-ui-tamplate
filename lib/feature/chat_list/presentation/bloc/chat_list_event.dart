part of 'chat_list_bloc.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

class ChatListStartStreamEvent extends ChatListEvent {

}

class ChatListDisplayEvent extends ChatListEvent{
  final List<types.Room> rooms;

  const ChatListDisplayEvent({required this.rooms});

  @override
  List<Object?> get props => [rooms];
}

class ChatListDeleteRoomEvent extends ChatListEvent{
  final types.Room room;

  const ChatListDeleteRoomEvent({required this.room});
}
