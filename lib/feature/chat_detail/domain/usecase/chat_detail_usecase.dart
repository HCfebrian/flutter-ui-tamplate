import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';
import 'package:simple_flutter/feature/chat_detail/domain/entity/message_entity.dart';

class ChatDetailUsecase {
  Future addMessageToDb({
    required MessageEntity messageEntity,
    required UserEntity sender,
    required UserEntity receiver,
  }) async {}

  Future addToSenderContact({
    required String senderId,
    required String receiverId,
    required DateTime currentTime,
  }) async {}

  Future addToReceiverContact({
    required String senderId,
    required String receiverId,
    required DateTime currentTime,
  }) async {}

  Future sendImageMsg({
    required String url,
    required String receiverId,
    required String senderId,
  }) async {}
}
