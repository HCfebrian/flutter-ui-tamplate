import 'package:simple_flutter/feature/contact_list/domain/entity/contact_entity.dart';

abstract class ContactListRepoAbs {
  Stream<List<ContactEntity>> fetchContacts({
    required String userId,
  });

  Stream<String> fetchLastMessageBetween({
    required String senderId,
    required String receiverId,
  });
}
