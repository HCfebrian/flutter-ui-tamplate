import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:simple_flutter/core/shared_feature/chat_util/domain/contract_repo/chat_user_repo_abs.dart';
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';

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
    // final meId = FirebaseAuth.instance.currentUser!.uid;
    // try{
    //   docs.forEach((element) {
    //     final data = element.get('status');
    //     final authorId = element.get('authorId');
    //     if (data == 'delivered' && authorId != meId) {
    //       unreadMessage = unreadMessage + 1;
    //     }
    //   });
    // }catch(e){
    //   log("error get user count : "+ e.toString());
    // }
    return unreadMessage.toString();
  }
}
