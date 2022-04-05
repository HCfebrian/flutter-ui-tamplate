import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:simple_flutter/feature/chat_detail/domain/usecase/chat_detail_usecase.dart';

import '../../../core/constant/static_constant.dart';

class BroadcastUsecase {
  final ChatDetailUsecase chatDetailUsecase;

  const BroadcastUsecase({required this.chatDetailUsecase});

  Future<List<String>> getRoomId(
      {required List<String> listUserId, required String myUserId}) async {
    log("get user room id");
    final List<String> allRoomId = [];
    final allMyRoom = await FirebaseFirestore.instance
        .collection(ROOM_COLLECTION)
        .where('userIds', arrayContains: myUserId)
        .get();
    log("get user room id " + allMyRoom.docs.length.toString());
    allMyRoom.docs.forEach((element) {
      log(myUserId);
      log(element.data()["userIds"].toString());
      var otherId = element.data()["userIds"];
      otherId.remove(myUserId);
      log(otherId.toString());
      log(listUserId.toString());
      if (listUserId.contains(otherId[0])) {
        allRoomId.add(element.id);
      }
    });
    log("get user room id jjj " + allRoomId.length.toString());
    return allRoomId;
  }

  Future sendTextBroadcast({
    required types.PartialText message,
    required List<String> listUserId,
    required String myUserId,
  }) async {
    log("send text Broadcast " + message.text);
    final allOtherRoomId =
        await getRoomId(listUserId: listUserId, myUserId: myUserId);
    log('send to ${allOtherRoomId.length} people');
    await Future.forEach(
      allOtherRoomId,
      (element) async {
        await chatDetailUsecase.sendTextMsg(
          partialText: message,
          roomId: element.toString(),
        );
      },
    );
    return;
  }

  Future sendFileBroadcast({
    required types.PartialFile message,
    required List<String> listUserId,
    required String myUserId,
  }) async {
    final allOtherRoomId =
        await getRoomId(listUserId: listUserId, myUserId: myUserId);
    log('send to ${allOtherRoomId.length} people');
    await Future.forEach(
      allOtherRoomId,
      (element) async {
        await chatDetailUsecase.sendFileMsg(
          partialFile: message,
          roomId: element.toString(),
        );
      },
    );
    return;
  }
}
