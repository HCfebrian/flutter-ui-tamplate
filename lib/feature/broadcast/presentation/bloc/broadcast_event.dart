part of 'broadcast_bloc.dart';

abstract class BroadcastEvent extends Equatable {
  const BroadcastEvent();
}

class BroadcastSendMessageEvent extends BroadcastEvent {
  final List<String> listUserId;
  final types.PartialText messages;

  const BroadcastSendMessageEvent({
    required this.listUserId,
    required this.messages,
  });

  @override
  List<Object?> get props => [];
}

class BroadcastSendFileMessageEvent extends BroadcastEvent {
  final List<String> listUserId;
  final types.PartialFile messages;

  const BroadcastSendFileMessageEvent({
    required this.listUserId,
    required this.messages,
  });

  @override
  List<Object?> get props => [];
}
