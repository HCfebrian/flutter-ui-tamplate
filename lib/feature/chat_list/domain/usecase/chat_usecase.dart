import 'package:simple_flutter/feature/chat_list/domain/contract_repo/chat_repo.dart';

class ChatUsecase{
  final ChatRepo chatListRepoAbs;

  ChatUsecase({required this.chatListRepoAbs});

  // Stream<String> getLastMessage(){
  //   chatListRepoAbs.getMessageStream().listen((event) {
  //   });
  // }

  static String getDisplayMessage(Map<String, dynamic> map){
    switch(map['type']){
      case "text":
        return "put text here";
      case "image":
        return "Image";
      case "file":
        return "File";
      default:
        return "";
    }
  }
}