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

  Future<UserEntity?> getUserData() async {
    return authRepoAbs.getUser();
  }

  Stream<UserEntity?> getUserDataStream() {
    return userRepoAbs.getUserDataStream();
  }
}
