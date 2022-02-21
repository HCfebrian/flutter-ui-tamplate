import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:simple_flutter/feature/auth/domain/contract_repo/user_repo_abs.dart';
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';

class UserRepoImpl implements UserRepoAbs {
  final FirebaseAuth firebaseAuth;
  final FirebaseMessaging firebaseMessaging;
  final FirebaseFirestore firestore;
  late StreamController<UserEntity?> userStream;

  UserRepoImpl(
      {required this.firebaseAuth,
      required this.firebaseMessaging,
      required this.firestore});

  @override
  Future<UserEntity> getUserData() {
    // TODO: implement getUserData
    throw UnimplementedError();
  }

  @override
  Stream<UserEntity?> getUserDataStream() {
    userStream = StreamController();
    firebaseAuth.authStateChanges().listen((event) {
      if (event != null) {
        userStream.add(
          UserEntity(
            id: event.uid,
            firstName: event.displayName ?? '',
            imageUrl: event.photoURL ?? '',
          ),
        );
      } else {
        userStream.add(null);
      }
    });
    return userStream.stream;
  }

  @override
  Future registerFcmToken({required String userId}) async {
    final String? token = await firebaseMessaging.getToken();
    if (token != null) {
      log('fcmTokenDevice $token');
      return firestore.doc("users/$userId").update({"fcmTokenDevice": token});
    } else {
      log("token fcm not found");
    }
  }
}
