import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';

abstract class UserRepoAbs {
  Future<UserEntity> getUserData();
  Stream<UserEntity?> getUserDataStream();
  Future registerFcmToken({required String userId});
}
