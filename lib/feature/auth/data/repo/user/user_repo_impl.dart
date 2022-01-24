import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_flutter/feature/auth/domain/contract_repo/user_repo_abs.dart';
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';

class UserRepoImpl implements UserRepoAbs {
  final FirebaseAuth firebaseAuth;
  late StreamController<UserEntity?> userStream;

  UserRepoImpl({required this.firebaseAuth});

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
            firstName: event.displayName ?? "",
            imageUrl: event.photoURL ?? "",
          ),
        );
      }
      else {
        userStream.add(null);
      }
    });
    return userStream.stream;
  }
}
