import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

abstract class ChatListRepoAbs{
  Stream<types.Message> getMessageStream();

  void deleteRoom({required types.Room room});
}
