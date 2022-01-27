import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;


abstract class ChatUserRepoAbs {
  Future registerUserChat({required UserEntity user});
  Future<types.User?> getUserById({required String userId});
}
