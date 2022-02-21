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

  Stream<UserEntity?> getUserDataStream() {
    return userRepoAbs.getUserDataStream();
  }

  Future registerFcmToken ({required String userId}){
    return userRepoAbs.registerFcmToken(userId: userId);
  }

}
