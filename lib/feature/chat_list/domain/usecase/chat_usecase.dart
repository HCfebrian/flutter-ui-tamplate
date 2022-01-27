import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:simple_flutter/feature/chat_list/domain/contract_repo/chat_repo.dart';


class ChatUsecase{
  final ChatListRepoAbs chatListRepoAbs;

  ChatUsecase({required this.chatListRepoAbs});


  static String getDisplayMessage(Map<String, dynamic> map){
    switch(map['type']){
      case 'text':
        return 'put text here';
      case 'image':
        return 'Image';
      case 'file':
        return 'File';
      default:
        return '';
    }
  }


  Future deleteRoom(types.Room room) async{
    chatListRepoAbs.deleteRoom(room: room);
  }

}
