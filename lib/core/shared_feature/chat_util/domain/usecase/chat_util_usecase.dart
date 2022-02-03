import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_flutter/core/shared_feature/chat_util/domain/contract_repo/chat_user_repo_abs.dart';
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatUtilUsecase {
  final ChatUserRepoAbs chatUserRepoAbs;

  ChatUtilUsecase({required this.chatUserRepoAbs});

  Future registerUserChat({required UserEntity userEntity}) async {
    chatUserRepoAbs.registerUserChat(user: userEntity);
  }

  Future<types.User?> getUserById({required String userId}) async {
    return chatUserRepoAbs.getUserById(userId: userId);
  }

  static String getDisplayMessage(Map<dynamic, dynamic>? map) {
    if (map != null) {
      switch (map['type']) {
        case 'text':
          return map['text'].toString();
        case 'image':
          return 'Image';
        case 'file':
          return 'File';
        default:
          return '';
      }
    } else {
      return '';
    }
  }

  static String getUnreadCount(List<QueryDocumentSnapshot<Object?>> docs) {
    int unreadMessage = 0;
    docs.forEach((element) {
      final data = element.get("status");
      if (data == "delivered") {
        unreadMessage = unreadMessage + 1;
      }
    });
    return unreadMessage.toString();
  }
}
