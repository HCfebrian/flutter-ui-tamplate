import 'package:simple_flutter/feature/chat_detail/domain/entity/message_entity.dart';

abstract class ChatRepo{
  Stream<MessageEntity> getMessageStream();
}
