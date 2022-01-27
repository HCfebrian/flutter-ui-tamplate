import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';
import 'package:simple_flutter/feature/chat_detail/domain/contract_repo/chat_detail_repo_abs.dart';


class ChatDetailUsecase {
  final ChatDetailRepoAbs chatDetailRepoAbs;

  ChatDetailUsecase({required this.chatDetailRepoAbs});

  Stream<List<types.Message>> initStream(types.Room room) {
    return chatDetailRepoAbs.initStream(room);
  }

  Future addMessageToDb({
    required types.Message messageEntity,
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

  Future deleteMessage({required types.Message message, required types.Room room}) async{

    chatDetailRepoAbs.deleteMessage(message: message, room: room);

    if(message is types.ImageMessage){
      chatDetailRepoAbs.deleteImageStorage(message: message, room: room);
    }

    if(message is types.FileMessage){
      chatDetailRepoAbs.deleteFile(message: message, room: room);
    }

  }
}
