import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:simple_flutter/core/constant/static_constant.dart';
import 'package:simple_flutter/feature/auth/domain/contract_repo/user_repo_abs.dart';
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';
import 'package:simple_flutter/utils/route_generator.dart';

class UserRepoImpl implements UserRepoAbs {
  final FirebaseAuth firebaseAuth;
  final FirebaseMessaging firebaseMessaging;
  final FirebaseFirestore firestore;
  final FirebaseDatabase database;

  late StreamController<UserEntity?> userStream;

  UserRepoImpl({
    required this.firebaseAuth,
    required this.firebaseMessaging,
    required this.firestore,
    required this.database,
  });

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
      return firestore.doc('users/$userId').update({'fcmTokenDevice': token});
    } else {
      log('token fcm not found');
    }
  }

  @override
  Future refreshFcmToken() {
    return firebaseMessaging.deleteToken();
  }

  @override
  Future listenOnlineStatus({required String userId}) async {
    log("handle user online status repo");
    final userStatusFirestoreRef = firestore.doc('$USER_COLLECTION/$userId');
    final userStatusDatabaseRef = database.ref('/status/$userId');

    final isOfflineForDatabase = {
      'state': 'offline',
      'last_changed': ServerValue.timestamp,
    };

    try {
      database.ref('.info/connected').onValue.listen((snapshot) {
        log("test 123");
        if (snapshot.snapshot.value == false) {
          setUserStatus(onlineOrOffline: "offline", userId: userId);
          return;
        }
        userStatusDatabaseRef.onDisconnect().set(isOfflineForDatabase).then((
          value,
        ) {
          log("listen is online");
          setUserStatus(onlineOrOffline: "online", userId: userId);
          return null;
        });
      });
    } catch (e) {
      log(e.toString());
    }
    return;
  }

  @override
  Future setUserStatus(
      {required String onlineOrOffline, required String userId}) async {
    final userStatusFirestoreRef = firestore.doc('$USER_COLLECTION/$userId');
    final userStatusDatabaseRef = database.ref('/status/$userId');

    final isOfflineForDatabase = {
      'state': 'offline',
      'last_changed': ServerValue.timestamp,
    };
    final isOnlineForDatabase = {
      'state': 'online',
      'last_changed': ServerValue.timestamp,
    };
    final isOfflineForFirestore = {
      'state': 'offline',
      'last_changed': FieldValue.serverTimestamp(),
    };
    final isOnlineForFirestore = {
      'state': 'online',
      'last_changed': FieldValue.serverTimestamp(),
    };

    if (onlineOrOffline == 'online') {
      userStatusDatabaseRef.set(isOnlineForDatabase);
      userStatusFirestoreRef.set(isOnlineForFirestore, SetOptions(merge: true));
    } else {
      userStatusDatabaseRef.set(isOfflineForDatabase);
      userStatusFirestoreRef.set(
        isOfflineForFirestore,
        SetOptions(merge: true),
      );
    }
  }
}
