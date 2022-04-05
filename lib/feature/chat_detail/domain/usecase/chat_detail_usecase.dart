import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:simple_flutter/feature/auth/domain/usecase/user_usecase.dart';
import 'package:simple_flutter/feature/chat_detail/domain/contract_repo/chat_detail_repo_abs.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/bloc/chat_detail_status/chat_detail_status_bloc.dart';

const int TYPING_DEBAUCE_DURATION = 3;

class ChatDetailUsecase {
  final ChatDetailRepoAbs chatDetailRepoAbs;
  final UserUsecase userUsecase;

  bool nexPageBusy = false;
  types.Room? currentRoom;

  StreamController<ChatStatus>? statusStream;

  bool isUserTyping = false;
  bool isUserOnline = false;
  DateTime? lastTypingDate;

  ChatDetailUsecase({
    required this.userUsecase,
    required this.chatDetailRepoAbs,
  });

  Stream<List<types.Message>> initStream(types.Room room) {
    currentRoom = null;
    currentRoom = room;
    return chatDetailRepoAbs.initStream(room);
  }

  Future sendTextMsg({
    required types.PartialText partialText,
    required String roomId,
    String? replayRefId,
    String? replayType,
    String? replayContent,
    String? replayToAuthorName,
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
    messageMap['metadata'] = {
      'replayTo': replayRefId,
      'replayType': replayType,
      'replayContent': replayContent,
      'replayToAuthorName': replayToAuthorName,
    };

    log("usecase send message data : $messageMap");

    chatDetailRepoAbs.sendMessage(message: messageMap, roomId: roomId);
  }

  Future sendFileMsg({
    required types.PartialFile partialFile,
    required String roomId,
    String? replayRefId,
    String? replayType,
    String? replayContent,
    String? replayToAuthorName,
  }) async {
    log('Send message');
    final user = await userUsecase.getUserData();
    final types.Message message = types.FileMessage.fromPartial(
      author: types.User(id: user!.id),
      id: '',
      partialFile: partialFile,
    );

    final messageMap = message.toJson();
    messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
    messageMap['authorId'] = user.id;
    messageMap['createdAt'] = FieldValue.serverTimestamp();
    messageMap['updatedAt'] = FieldValue.serverTimestamp();
    messageMap['metadata'] = {
      'replayTo': replayRefId,
      'replayType': replayType,
      'replayContent': replayContent,
      'replayToAuthorName': replayToAuthorName,
    };

    log("usecase send message data : $messageMap");

    chatDetailRepoAbs.sendMessage(message: messageMap, roomId: roomId);
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

  Future<String> uploadImage({
    required String path,
    required String fileName,
  }) async {
    final file = File(path);
    final uri = await chatDetailRepoAbs.uploadImageStorage(
        file: file, fileName: fileName);
    if (uri != null) {
      return uri;
    } else {
      throw Exception("uri not found");
    }
  }

  Future sendImageMsg({
    required String uri,
    required String path,
    required String fileName,
    required String room,
  }) async {
    if (uri != null || uri.isNotEmpty) {
      final file = File(path);
      final size = file.lengthSync();
      final bytes = await file.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final user = await userUsecase.getUserData();
      final message = types.PartialImage(
        height: image.height.toDouble(),
        name: fileName,
        size: size,
        uri: uri,
        width: image.width.toDouble(),
      );

      final messageMap = message.toJson();
      messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
      messageMap['authorId'] = user?.id;
      messageMap['createdAt'] = FieldValue.serverTimestamp();
      messageMap['updatedAt'] = FieldValue.serverTimestamp();
      messageMap['type'] = 'image';
      messageMap['metadata'] = {};

      chatDetailRepoAbs.sendMessage(message: messageMap, roomId: room);
    }
  }

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
    if (!isUserTyping) {
      print('typing user $myUserId');
      isUserTyping = true;
      chatDetailRepoAbs.setTypingStatusDate(
        date: DateTime.now(),
        room: room,
        myUserId: myUserId,
      );
      Future.delayed(const Duration(seconds: TYPING_DEBAUCE_DURATION))
          .then((value) {
        statusStream!.add(ChatStatus.offline);
        isUserTyping = false;
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
    isUserOnline = false;

    chatDetailRepoAbs
        .startOnlineStatusStream(room: room, otherUserId: otherUserId)
        .listen((isOnline) {
      if (isOnline) {
        isUserOnline = true;
        statusStream!.add(ChatStatus.online);
      } else {
        isUserOnline = false;
        statusStream!.add(ChatStatus.offline);
      }
    });

    chatDetailRepoAbs
        .startLastTypingStream(room: room, otherUserId: otherUserId)
        .listen((lastTypeDate) {
      final now = DateTime.now();
      if (now.difference(lastTypeDate) <
          const Duration(seconds: TYPING_DEBAUCE_DURATION)) {
        statusStream!.add(ChatStatus.typing);
        Future.delayed(const Duration(seconds: TYPING_DEBAUCE_DURATION))
            .then((value) {
          isUserTyping = false;
          if (isUserOnline) {
            statusStream!.add(ChatStatus.online);
          } else {
            statusStream!.add(ChatStatus.offline);
          }
        });
      }
    });
    return statusStream!.stream;
  }

  Future nextPage() async {
    if (!nexPageBusy) {
      nexPageBusy = true;
      await chatDetailRepoAbs.nextPage(
        page: 2,
        room: currentRoom!,
      );
      nexPageBusy = false;
    }
    return;
  }
}
