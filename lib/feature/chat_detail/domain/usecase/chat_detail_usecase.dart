import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:simple_flutter/feature/auth/domain/usecase/user_usecase.dart';
import 'package:simple_flutter/feature/chat_detail/domain/contract_repo/chat_detail_repo_abs.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/bloc/chat_detail_status/chat_detail_status_bloc.dart';

const int TYPING_DEBAUCE_DURATION = 3;

class ChatDetailUsecase {
  final ChatDetailRepoAbs chatDetailRepoAbs;
  final UserUsecase userUsecase;

  StreamController<ChatStatus>? statusStream;

  bool isTyping = false;
  DateTime? lastTypingDate;

  ChatDetailUsecase({
    required this.userUsecase,
    required this.chatDetailRepoAbs,
  });

  Stream<List<types.Message>> initStream(types.Room room) {
    return chatDetailRepoAbs.initStream(room);
  }

  Future addMessageToDb({
    required types.PartialText partialText,
    required types.Room roomId,
  }) async {
    log('Send message');
    final user = await userUsecase.getUserData();
    final types.Message message = types.TextMessage.fromPartial(
      author: types.User(id: user!.id),
      id: '',
      partialText: partialText,
    );


    final messageMap = message.toJson();
    messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
    messageMap['authorId'] = user.id;
    messageMap['createdAt'] = FieldValue.serverTimestamp();
    messageMap['updatedAt'] = FieldValue.serverTimestamp();

    log("usecase send message data : $messageMap");
    log("room : " + roomId.id);

    chatDetailRepoAbs.sendMessage(message: messageMap, room: roomId);
  }

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

  Future deleteMessage(
      {required types.Message message, required types.Room room}) async {
    chatDetailRepoAbs.deleteMessage(message: message, room: room);

    if (message is types.ImageMessage) {
      chatDetailRepoAbs.deleteImageStorage(message: message, room: room);
    }

    if (message is types.FileMessage) {
      chatDetailRepoAbs.deleteFile(message: message, room: room);
    }
  }

  Future markAsRead(
      {required types.Message message, required types.Room room}) {
    return chatDetailRepoAbs.markAsRead(message: message, room: room);
  }

  // Future markAsDelivered({required types.Message message, required types.Room room}){
  //   return chatDetailRepoAbs.markAsDelivered(message: message, room: room);
  // }

  Future typingStatus({
    required types.Room room,
    required String myUserId,
  }) async {
    if (!isTyping) {
      print("typing bosku " + myUserId.toString());
      isTyping = true;
      chatDetailRepoAbs.setTypingStatusDate(
        date: DateTime.now(),
        room: room,
        myUserId: myUserId,
      );
      Future.delayed(const Duration(seconds: TYPING_DEBAUCE_DURATION))
          .then((value) {
        statusStream!.add(ChatStatus.offline);
        isTyping = false;
      });
    }
  }

  Stream<ChatStatus> statusStartStream({
    required types.Room room,
    required String otherUserId,
  }) {
    statusStream?.close();
    statusStream = null;
    statusStream ??= StreamController();
    chatDetailRepoAbs
        .startLastTypingStream(room: room, otherUserId: otherUserId)
        .listen((event) {
      final now = DateTime.now();
      if (now.difference(event) <
          const Duration(seconds: TYPING_DEBAUCE_DURATION)) {
        statusStream!.add(ChatStatus.typing);
        Future.delayed(const Duration(seconds: TYPING_DEBAUCE_DURATION))
            .then((value) {
          statusStream!.add(ChatStatus.offline);
        });
      }
    });
    return statusStream!.stream;
  }
}
