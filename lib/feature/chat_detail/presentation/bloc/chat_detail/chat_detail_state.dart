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

  const ChatDetailLoadedState({required this.listMessage});
  @override
  List<Object> get props => [];
}
class ChatDetailInitial extends ChatDetailState {
  @override
  List<Object> get props => [];
}
