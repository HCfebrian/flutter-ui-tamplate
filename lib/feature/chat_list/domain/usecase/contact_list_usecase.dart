import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';
import 'package:simple_flutter/feature/chat_list/domain/contract_repo/chat_list_repo_abs.dart';
import 'package:simple_flutter/feature/chat_list/domain/entity/contact_entity.dart';

class ContactListUsecase {
  final ChatListRepoAbs chatListRepo;

  ContactListUsecase({required this.chatListRepo});

  Stream<List<ContactEntity>> fetchContacts({
    required String userId,
  }) {
    return chatListRepo.fetchContacts(userId: userId);
  }

  Stream<String> fetchLastMessageBetween({
    required String senderId,
    required String receiverId,
  }) {
    return chatListRepo.fetchLastMessageBetween(
      senderId: senderId,
      receiverId: receiverId,
    );
  }
}
