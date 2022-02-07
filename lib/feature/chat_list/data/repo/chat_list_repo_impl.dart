import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/src/message.dart';
import 'package:flutter_chat_types/src/room.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:simple_flutter/core/constant/static_constant.dart';
import 'package:simple_flutter/feature/chat_list/domain/contract_repo/chat_repo.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatListRepoImpl implements ChatListRepoAbs {
  final FirebaseFirestore firestore;

  ChatListRepoImpl({required this.firestore});

  @override
  Future<void> deleteRoom({required Room room}) async {
    // FirebaseChatCore.instance.deleteRoom(room.id);
    final documents = await firestore
        .collection(ROOM_COLLECTION)
        .doc(room.id)
        .collection(MESSAGE_COLLECTION)
        .get();

    documents.docs.forEach((element) {
      firestore
          .collection(ROOM_COLLECTION)
          .doc(room.id)
          .collection(MESSAGE_COLLECTION)
          .doc(element.id)
          .update({
        'metadata': {
          'isDeleted-${FirebaseAuth.instance.currentUser!.uid}': true
        }
      });
    });

    FirebaseChatCore.instance.updateRoom(room.copyWith(metadata: {
      'isDeleted-${FirebaseAuth.instance.currentUser!.uid}': true
    }));
    List<types.User> users = [];
    users.addAll(room.users);
    if (room.users.length < 2) {
      users.add(types.User(id: FirebaseAuth.instance.currentUser!.uid));
    }
    List<String> userID = [];
    users.forEach((element) {
      userID.add(element.id);
    });
    firestore
        .collection(ROOM_COLLECTION)
        .doc(room.id)
        .update({"userIds": userID});
    return;
  }

  @override
  Stream<Message> getMessageStream() {
    // TODO: implement getMessageStream
    throw UnimplementedError();
  }
}
