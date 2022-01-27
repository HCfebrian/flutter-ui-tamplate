import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

abstract class ChatDetailRepoAbs {
  Stream<List<types.Message>> initStream(types.Room room);

  void dispose();

  Future deleteMessage({required types.Message message, required types.Room room});
  Future deleteImageStorage({required types.ImageMessage message, required types.Room room});
  Future deleteFile({required types.FileMessage message,required types.Room room});
}
