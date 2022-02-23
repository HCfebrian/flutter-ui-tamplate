import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

import 'package:simple_flutter/core/constant/static_constant.dart';
import 'package:simple_flutter/feature/chat_detail/domain/contract_repo/chat_detail_repo_abs.dart';

class ChatDetailRepoImpl implements ChatDetailRepoAbs {
  final FirebaseFirestore firestore;
  final FirebaseStorage firebaseStorage;
  StreamController<List<types.Message>>? messageStream;
  StreamSubscription? dbRealtimeStream;
  StreamController<DateTime>? lastTypingStream;
  final fetchCount = 20;
  int limit = 20;

  ChatDetailRepoImpl({
    required this.firestore,
    required this.firebaseStorage,
  });

  @override
  Stream<List<types.Message>> initStream(types.Room room) {
    messageStream?.close();
    messageStream = null;
    messageStream ??= StreamController();
    limit = fetchCount;

    // dbRealtimeStream = firestore.collection("$ROOM_COLLECTION/${room.id}/$MESSAGE_COLLECTION").snapshots().listen((event) {
    //   List<types.Message> message = [];
    //   // event.forEach((element) {
    //   //   if (element.metadata?[
    //   //           'isDeleted-${FirebaseAuth.instance.currentUser!.uid}'] ==
    //   //       true) {
    //   //   } else {
    //   //     message.add(element);
    //   //   }
    //   // });
    //
    //   messageStream!.add(message);
    // });

    dbRealtimeStream = FirebaseChatCore.instance
        .messages(
      room,
      limit: limit,
    )
        .listen((event) {
      final filteredMessage = excludeDeletedMessage(unfilteredMessage: event);
      messageStream!.add(filteredMessage);
    });

    return messageStream!.stream;
  }

  @override
  void dispose() {
    dbRealtimeStream?.cancel();
    dbRealtimeStream = null;
  }

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
  Future deleteFile(
      {required types.FileMessage message, required types.Room room}) {
    return firebaseStorage.refFromURL(message.uri).delete();
  }

  @override
  Future setTypingStatusDate(
      {required DateTime date,
      required types.Room room,
      required String myUserId}) async {
    firestore
        .collection(ROOM_COLLECTION)
        .doc(room.id)
        .update({'isTyping-$myUserId': date});
  }

  @override
  Stream<DateTime> startLastTypingStream({
    required types.Room room,
    required String otherUserId,
  }) {
    lastTypingStream?.close();
    lastTypingStream = null;
    lastTypingStream ??= StreamController();

    firestore
        .collection(ROOM_COLLECTION)
        .doc(room.id)
        .snapshots()
        .listen((event) {
      if (event.exists &&
          event.data() != null &&
          event.data()!['isTyping-$otherUserId'] != null) {
        lastTypingStream!.add(
            (event.data()!['isTyping-$otherUserId'] as Timestamp).toDate());
      }
    });
    return lastTypingStream!.stream;
  }

  @override
  Future markAsRead(
      {required types.Message message, required types.Room room}) async {
    return firestore
        .collection(ROOM_COLLECTION)
        .doc(room.id)
        .collection(MESSAGE_COLLECTION)
        .doc(message.id)
        .update({'status': types.Status.seen.name});
  }

  @override
  Future sendMessage(
      {required Map<String, dynamic> message, required types.Room room}) async {
    log('send message data layer : $message');
    try {
      return firestore
          .collection('$ROOM_COLLECTION/${room.id}/messages')
          .add(message);
    } catch (e) {
      log('error firebase $e');
      return;
    }
  }

  List<types.Message> excludeDeletedMessage(
      {required List<types.Message> unfilteredMessage}) {
    final List<types.Message> filteredMessage = [];

    unfilteredMessage.forEach((element) {
      if (element.metadata?[
              'isDeleted-${FirebaseAuth.instance.currentUser!.uid}'] ==
          true) {
      } else {
        filteredMessage.add(element);
      }
    });
    return filteredMessage;
  }

  @override
  Future nextPage({
    required int page,
    required types.Room room,
  }) async {
    log('next page data layer limit : $limit');
    limit = limit + fetchCount;
    dbRealtimeStream?.cancel();
    dbRealtimeStream = null;
    dbRealtimeStream = FirebaseChatCore.instance
        .messages(
      room,
      limit: limit,
    )
        .listen((event) {
      final filteredMessage = excludeDeletedMessage(unfilteredMessage: event);
      messageStream!.add(filteredMessage);
    });

    return;
  }

// @override
// Future markAsDelivered(
//     {required types.Message message, required types.Room room}) async {
//   return firestore
//       .collection(ROOM_COLLECTION)
//       .doc(room.id)
//       .collection(MESSAGE_COLLECTION)
//       .doc(message.id)
//       .update({'status': types.Status.delivered.name});
// }
}
