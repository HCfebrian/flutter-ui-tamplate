import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

abstract class ChatRepo{
  Stream<types.Message> getMessageStream();
}
