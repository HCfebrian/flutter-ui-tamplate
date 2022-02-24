import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:simple_flutter/core/constant/static_constant.dart';
import 'package:simple_flutter/feature/auth/domain/contract_repo/auth_repo_abs.dart';
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';

class AuthFirebaseImpl implements AuthRepoAbs {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  late StreamController<UserEntity> streamUserEntity;

  AuthFirebaseImpl({required this.firebaseAuth, required this.firestore});

  @override
  Stream<UserEntity> initService() {
    streamUserEntity = StreamController<UserEntity>();
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event != null) {
        streamUserEntity.add(
          UserEntity(
            id: event.uid,
            firstName: event.displayName ?? '',
            imageUrl: event.photoURL ?? '',
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
  Future<String> loginUser({
    required String email,
    required String password,
    String? username,
  }) async {
    final userCredential = await firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password)
        .onError((error, stackTrace) {
      print('loganberry');
      throw Exception('login failed');
    });
    return userCredential.credential!.token.toString();
  }

  @override
  Future<String> registerUser({
    required String email,
    required String password,
    required String username,
  }) async {
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    print('user id registered as ${userCredential.user?.uid}');
    firestore.doc('$USER_COLLECTION/${userCredential.user?.uid}').set(
          types.User(
            firstName: username,
            id: userCredential.user!.uid,
            imageUrl: 'https://i.pravatar.cc/300?u=$email',
            lastName: '',
          ).toJson(),
        );
    // await FirebaseChatCore.instance.createUserInFirestore(
    //   types.User(
    //     firstName: username,
    //     id: userCredential.user!.uid,
    //     imageUrl: 'https://i.pravatar.cc/300?u=$email',
    //     lastName: '',
    //   ),
    // );
    return (userCredential.credential?.token).toString();
  }

  @override
  Future loginGoogleOauth() async {
    print("login google o auth");
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
    final result = await firebaseAuth.signInWithCredential(credential);

    firestore.doc('$USER_COLLECTION/${result.user?.uid}').set(
          types.User(
            firstName: result.user!.displayName,
            id: result.user!.uid,
            imageUrl: result.user!.photoURL,
            lastName: '',
          ).toJson(),
        );
    return result;
  }

  @override
  Future<UserEntity?> getUser() async {
    final user = firebaseAuth.currentUser;
    log('final user $user');
    if (user != null) {
      return UserEntity(
        id: user.uid,
        firstName: user.displayName ?? '',
        imageUrl: user.photoURL ?? '',
      );
    } else {
      return null;
    }
  }

  @override
  Future logout() async {
    GoogleSignIn().signOut();
    return firebaseAuth.signOut();
  }
}
