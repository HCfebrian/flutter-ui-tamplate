part of 'chat_loading_bloc.dart';

abstract class ChatLoadingState extends Equatable {
  const ChatLoadingState();
}

class ChatLoadingInitial extends ChatLoadingState {
  @override
  List<Object> get props => [];
}

class ChatLoadingProcessState extends ChatLoadingState {
  @override
  List<Object?> get props => [];
}

class ChatLoadingTransformState extends ChatLoadingState {
  @override
  List<Object?> get props => [];
}
