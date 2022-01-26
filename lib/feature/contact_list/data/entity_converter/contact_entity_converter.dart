import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_flutter/feature/contact_list/domain/entity/contact_entity.dart';

class ContactEntityConverter {
  static ContactEntity fromDocument({required QueryDocumentSnapshot doc}) {
    return ContactEntity(
      uid: doc['contact_id'].toString(),
      addOn: DateTime.parse(doc['added_on'].toDate().toString()),
    );
  }
}
