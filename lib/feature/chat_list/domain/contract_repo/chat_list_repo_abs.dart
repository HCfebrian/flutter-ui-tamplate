import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';
import 'package:simple_flutter/feature/chat_list/domain/entity/contact_entity.dart';

abstract class ChatListRepoAbs {
  Stream<List<ContactEntity>> fetchContacts({
    required String userId,
  });

  Stream<String> fetchLastMessageBetween({
    required String senderId,
    required String receiverId,
  });
}
