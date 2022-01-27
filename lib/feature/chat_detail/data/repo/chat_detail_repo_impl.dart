import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:simple_flutter/core/constant/static_constant.dart';
import 'package:simple_flutter/feature/chat_detail/domain/contract_repo/chat_detail_repo_abs.dart';

class ChatDetailRepoImpl implements ChatDetailRepoAbs {
  final FirebaseFirestore firestore;
  final FirebaseStorage firebaseStorage;
  StreamController<List<types.Message>>? messageStream;

  ChatDetailRepoImpl({
    required this.firestore,
    required this.firebaseStorage,
  });

  @override
  Stream<List<types.Message>> initStream(types.Room room) {
    messageStream?.close();
    messageStream = null;
    messageStream ??= StreamController();
    FirebaseChatCore.instance.messages(room).listen((event) {
      messageStream!.add(event);
    });
    return messageStream!.stream;
  }

  @override
  void dispose() {}

  @override
  Future deleteMessage(
      {required types.Message message, required types.Room room}) async {
    firestore
        .collection(ROOM_COLLECTION)
        .doc(room.id)
        .collection(MESSAGE_COLLECTION)
        .doc(message.id)
        .delete();
  }

  @override
  Future deleteImageStorage(
      {required types.ImageMessage message, required types.Room room}) async {
    return firebaseStorage.refFromURL(message.uri).delete();
  }

  @override
  Future deleteFile({required types.FileMessage message, required types.Room room}) {
    return firebaseStorage.refFromURL(message.uri).delete();
  }
}
