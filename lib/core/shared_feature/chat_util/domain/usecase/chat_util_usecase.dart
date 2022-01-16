import 'package:simple_flutter/core/shared_feature/chat_util/domain/contract_repo/chat_user_repo_abs.dart';
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';

class ChatUtilUsecase{
  final ChatUserRepoAbs chatUserRepoAbs;

  ChatUtilUsecase({required this.chatUserRepoAbs});

  Future registerUserChat({required UserEntity userEntity}) async{
    chatUserRepoAbs.registerUserChat(user: userEntity);
  }
}
