part of 'chat_detail_bloc.dart';

abstract class ChatDetailState extends Equatable {
  const ChatDetailState();
}

class ChatDetailLoadingState extends ChatDetailState {
  @override
  List<Object> get props => [];
}

class ChatDetailErrorState extends ChatDetailState {
  @override
  List<Object> get props => [];
}

class ChatDetailLoadedState extends ChatDetailState {
  final List<types.Message> listMessage;
  final bool isLoading;

  const ChatDetailLoadedState({
    required this.listMessage,
    required this.isLoading,
  });

  @override
  List<Object> get props => [];
}

class ChatDetailInitial extends ChatDetailState {
  @override
  List<Object> get props => [];
}
