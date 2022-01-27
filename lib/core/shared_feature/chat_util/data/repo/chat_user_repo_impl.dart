import 'dart:developer';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:simple_flutter/core/constant/static_constant.dart';
import 'package:simple_flutter/core/shared_feature/chat_util/domain/contract_repo/chat_user_repo_abs.dart';
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';

class ChatUserRepoImpl implements ChatUserRepoAbs {
  final FirebaseFirestore firebaseFirestore;

  ChatUserRepoImpl({required this.firebaseFirestore});

  @override
  Future registerUserChat({required UserEntity user}) async {
    log('register user id ${user.id}');
    // final userRef = firebaseFirestore.collection('user');
    // await userRef.doc(user.id).set({
    //   'uid': user.id,
    //   'displayName': user.firstName,
    //   'photoUrl': user.imageUrl
    // });

    final userRef = firebaseFirestore.collection(USER_COLLECTION);
    await userRef.doc(user.id).set(
          types.User(
            id: user.id,
            updatedAt: DateTime.now().microsecond,
            firstName: user.firstName,
            imageUrl: user.imageUrl,
          ).toJson(),
        );
    return;
  }

  @override
  Future<types.User?> getUserById({required String userId}) async {
    final userFinal =
        await firebaseFirestore.collection(USER_COLLECTION).doc(userId).get();
    try {
      return types.User.fromJson(userFinal.data()!);
    } catch (e) {
      return null;
    }
  }
}
