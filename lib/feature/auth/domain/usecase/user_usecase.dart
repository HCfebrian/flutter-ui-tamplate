import 'dart:developer';

import 'package:simple_flutter/feature/auth/domain/contract_repo/auth_repo_abs.dart';
import 'package:simple_flutter/feature/auth/domain/contract_repo/user_repo_abs.dart';
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';

class UserUsecase {
  final AuthRepoAbs authRepoAbs;
  final UserRepoAbs userRepoAbs;

  UserUsecase({
    required this.userRepoAbs,
    required this.authRepoAbs,
  });

  Future<void> init() async {
    authRepoAbs.initService();
  }

  Future<UserEntity?> getUserData() async {
    return authRepoAbs.getUser();
  }

  Future handleUserOnlineStatus() async {
    log('handle user online uses');
    final user = await authRepoAbs.getUser();
    return userRepoAbs.listenOnlineStatus(userId: user!.id);
  }

  Stream<UserEntity?> getUserDataStream() {
    return userRepoAbs.getUserDataStream();
  }

  Future registerFcmToken({required String userId}) {
    return userRepoAbs.registerFcmToken(userId: userId);
  }

  Future refreshFcmToken() {
    return userRepoAbs.refreshFcmToken();
  }

  Future setUserStatus({required bool isUserOnline}) async {
    final user = await getUserData();
    return userRepoAbs.setUserStatus(
      onlineOrOffline: isUserOnline ? 'online' : 'offline',
      userId: user!.id,
    );
  }
}
