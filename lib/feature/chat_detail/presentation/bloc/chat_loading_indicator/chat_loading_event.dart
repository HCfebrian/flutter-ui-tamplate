part of 'chat_loading_bloc.dart';

abstract class ChatLoadingEvent extends Equatable {
  const ChatLoadingEvent();
}

class ChatLoadingSetDataEvent extends ChatLoadingEvent {
  final bool isLoading;

  const ChatLoadingSetDataEvent({required this.isLoading});

  @override
  List<Object?> get props => [isLoading];
}
