import 'dart:async';
import 'dart:developer';

import 'package:couchbase_lite/couchbase_lite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:simple_flutter/feature/auth/domain/contract_repo/auth_repo_abs.dart';
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';

class AuthFirebaseImpl implements AuthRepoAbs {
  final FirebaseAuth firebaseAuth;

  late StreamController<UserEntity> streamUserEntity;

  AuthFirebaseImpl({
    required this.firebaseAuth,
  });

  Stream<UserEntity> initService() {
    streamUserEntity = StreamController<UserEntity>();
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event != null) {
        streamUserEntity.add(
          UserEntity(
            id: event.uid,
            name: event.displayName ?? "",
            photoUrl: event.photoURL ?? "",
          ),
        );
      }
    });
    return streamUserEntity.stream;
  }

  @override
  Future cancelRequest() {
    // TODO: implement cancelRequest
    throw UnimplementedError();
  }

  @override
  Future<String> loginUser(
      {required String email,
      required String password,
      String? username}) async {
    final userCredential = await firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password)
        .onError((error, stackTrace) {
      print("loginerror");
      throw Exception("login failed");
    });
    return userCredential.credential!.token.toString();
  }

  @override
  Future<String> registerUser(
      {required String email,
      required String password,
      required String username}) async {
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    // await FirebaseChatCore.instance.createUserInFirestore(
    //   types.User(
    //     firstName: username,
    //     id: userCredential.user!.uid,
    //     imageUrl: 'https://i.pravatar.cc/300?u=$email',
    //     lastName: "",
    //   ),
    // );

    MutableDocument doc = MutableDocument().setMap(
      "Users",
      types.User(
              id: userCredential.user!.uid,
              firstName: username,
              imageUrl: 'https://i.pravatar.cc/300?u=$email')
          .toJson(),
    );

    // couchBaseDb.saveDocument(doc);
    print("save document user" + doc.toMap().toString());

    return userCredential.credential!.token.toString();
  }

  @override
  Future loginGoogleOauth() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    // Once signed in, return the UserCredential
    return firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<UserEntity?> getUser() async {
    final user = firebaseAuth.currentUser;
    log('final user $user');
    if (user != null) {
      return UserEntity(
        id: user.uid,
        name: user.displayName ?? "",
        photoUrl: user.photoURL ?? "",
      );
    } else {
      return null;
    }
  }

  @override
  Future logout() async {
    return firebaseAuth.signOut();
  }
}
