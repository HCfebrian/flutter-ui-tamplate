import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';

abstract class UserRepoAbs{
  Future<UserEntity> getUserData();

}
