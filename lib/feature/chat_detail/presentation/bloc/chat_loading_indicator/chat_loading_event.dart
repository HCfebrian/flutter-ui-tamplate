part of 'chat_loading_bloc.dart';

abstract class ChatLoadingEvent extends Equatable {
  const ChatLoadingEvent();
}

class ChatLoadingUploadImageEvent extends ChatLoadingEvent {
  final String pathImage;
  final String fileName;
  final types.Room room;

  const ChatLoadingUploadImageEvent({
    required this.pathImage,
    required this.fileName,
    required this.room,
  });

  @override
  List<Object?> get props => [pathImage, fileName];
}
