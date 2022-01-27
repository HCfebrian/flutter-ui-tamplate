import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/src/message.dart';
import 'package:flutter_chat_types/src/room.dart';
import 'package:simple_flutter/core/constant/static_constant.dart';
import 'package:simple_flutter/feature/chat_list/domain/contract_repo/chat_repo.dart';

class ChatListRepoImpl implements ChatListRepoAbs {
  final FirebaseFirestore firestore;

  ChatListRepoImpl({required this.firestore});

  @override
  void deleteRoom({required Room room}) {
    firestore.collection(ROOM_COLLECTION).doc(room.id).delete();
  }

  @override
  Stream<Message> getMessageStream() {
    // TODO: implement getMessageStream
    throw UnimplementedError();
  }
}
