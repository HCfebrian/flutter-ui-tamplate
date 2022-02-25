import 'dart:io';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

abstract class ChatDetailRepoAbs {
  Stream<List<types.Message>> initStream(types.Room room);

  void dispose();

  Future sendMessage({
    required Map<String, dynamic> message,
    required types.Room room,
  });

  Future deleteMessage({
    required types.Message message,
    required types.Room room,
  });

  Future<String> uploadImageStorage({required File file, required String fileName});

  Future deleteImageStorage({
    required types.ImageMessage message,
    required types.Room room,
  });

  Future deleteFile({
    required types.FileMessage message,
    required types.Room room,
  });

  Future setTypingStatusDate({
    required DateTime date,
    required types.Room room,
    required String myUserId,
  });

  Stream<DateTime> startLastTypingStream({
    required types.Room room,
    required String otherUserId,
  });

  Stream<bool> startOnlineStatusStream({
    required types.Room room,
    required String otherUserId,
  });

  Future markAsRead({
    required types.Message message,
    required types.Room room,
  });

  Future nextPage({
    required int page,
    required types.Room room,
  });
// Future markAsDelivered({
//   required types.Message message,
//   required types.Room room,
// });
}
