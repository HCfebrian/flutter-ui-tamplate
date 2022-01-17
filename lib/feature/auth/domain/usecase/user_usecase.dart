import 'package:simple_flutter/core/utils/user_state_enum.dart';
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

  Future<UserEntity?> getMeData() async {
    return authRepoAbs.getUser();
  }

  Stream<UserEntity?> getMeDataStream() {
    return userRepoAbs.getUserDataStream();
  }

  // Future<List<UserEntity>> fetchAllUsers({required UserEntity currentUser}) async {}


  void setUserState({required String userId, required UserState userState}) {
    // int stateNum = StateUtil.stateToNum(userState);

    // _userCollection.document(userId).updateData({"state": stateNum});
  }

  // Stream<UserEntity> getUserStream({@required String uid}) {
  //   // return _userCollection.document(uid).snapshots();
  // }

}
