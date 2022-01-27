part of 'chat_detail_status_bloc.dart';

abstract class ChatDetailStatusState extends Equatable {
  const ChatDetailStatusState();
}

class ChatDetailStatusInitial extends ChatDetailStatusState {
  @override
  List<Object> get props => [];
}

class ChatDetailCurrentStatus extends ChatDetailStatusState {
  final ChatStatus chatStatus;

  const ChatDetailCurrentStatus({required this.chatStatus});

  @override
  List<Object?> get props => [chatStatus];
}
