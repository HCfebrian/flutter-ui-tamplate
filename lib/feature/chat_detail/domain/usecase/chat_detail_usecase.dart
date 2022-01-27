import 'dart:async';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';
import 'package:simple_flutter/feature/chat_detail/domain/contract_repo/chat_detail_repo_abs.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/bloc/chat_detail_status/chat_detail_status_bloc.dart';

const int TYPING_DEBAUCE_DURATION = 3;

class ChatDetailUsecase {
  final ChatDetailRepoAbs chatDetailRepoAbs;

  StreamController<ChatStatus>? statusStream;

  bool isTyping = false;
  DateTime? lastTypingDate;

  ChatDetailUsecase({
    required this.chatDetailRepoAbs,
  });

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

  Future typingStatus({
    required types.Room room,
    required String myUserId,
  }) async {
    if (!isTyping) {
      print("typing bosku "+ myUserId.toString());
      isTyping = true;
      chatDetailRepoAbs.setTypingStatusDate(
        date: DateTime.now(),
        room: room,
        myUserId: myUserId,
      );
      Future.delayed(const Duration(seconds: TYPING_DEBAUCE_DURATION))
          .then((value) {
        statusStream!.add(ChatStatus.online);
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
    chatDetailRepoAbs.startLastTypingStream(room: room, otherUserId: otherUserId).listen((event) {
      final now = DateTime.now();
      if (now.difference(event) <
          const Duration(seconds: TYPING_DEBAUCE_DURATION)) {
        statusStream!.add(ChatStatus.typing);
        Future.delayed(const Duration(seconds: TYPING_DEBAUCE_DURATION))
            .then((value) {
          statusStream!.add(ChatStatus.online);
        });
      }
    });
    return statusStream!.stream;
  }
}
