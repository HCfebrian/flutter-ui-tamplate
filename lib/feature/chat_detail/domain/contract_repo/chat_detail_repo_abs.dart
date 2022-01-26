import 'package:flutter_chat_types/flutter_chat_types.dart' as types;


abstract class ChatDetailRepoAbs{
  Stream<List<types.Message>> initStream(types.Room room);
  void dispose();
}
