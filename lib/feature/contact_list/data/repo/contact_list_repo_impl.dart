import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_flutter/core/constant/static_constant.dart';
import 'package:simple_flutter/feature/contact_list/data/entity_converter/contact_entity_converter.dart';
import 'package:simple_flutter/feature/contact_list/domain/contract_repo/contact_list_repo_abs.dart';
import 'package:simple_flutter/feature/contact_list/domain/entity/contact_entity.dart';

class ContactListRepoImpl implements ContactListRepoAbs {
  final FirebaseFirestore firebaseFirestore;
  StreamController<List<ContactEntity>> userEntityStreamControl =
      StreamController();
  StreamController<String> lastMessages = StreamController();

  ContactListRepoImpl({required this.firebaseFirestore});

  @override
  Stream<List<ContactEntity>> fetchContacts({required String userId}) {
    firebaseFirestore
        .collection(USER_COLLECTION)
        .doc(userId)
        .collection(CONTACT_COLLECTION)
        .snapshots()
        .listen((event) async {
      final List<ContactEntity> listContact = [];
      await Future.forEach(event.docs, (element) {
        listContact.add(ContactEntityConverter.fromDocument(
            doc: element as QueryDocumentSnapshot));
        return null;
      });
      userEntityStreamControl.add(listContact);
    });
    return userEntityStreamControl.stream;
  }

  @override
  Stream<String> fetchLastMessageBetween({
    required String senderId,
    required String receiverId,
  }) {
    firebaseFirestore
        .collection(MESSAGE_COLLECTION)
        .doc(senderId)
        .collection(receiverId)
        .orderBy('timestamp')
        .snapshots()
        .listen((event) async {
      lastMessages.add(event.docs.first.data()['message'].toString());
    });
    return lastMessages.stream;
  }
}
