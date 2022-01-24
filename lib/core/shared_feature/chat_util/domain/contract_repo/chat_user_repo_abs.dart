import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';

abstract class ChatUserRepoAbs {
  Future registerUserChat({required UserEntity user});
}
