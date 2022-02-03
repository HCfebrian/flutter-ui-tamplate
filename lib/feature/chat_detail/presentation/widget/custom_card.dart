import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simple_flutter/core/shared_feature/chat_util/domain/usecase/chat_util_usecase.dart';

class ChatModel {
  String name;
  String? icon;
  bool? isGroup;
  String time;
  String currentMessage;
  String status;
  bool select = false;
  int? id;

  ChatModel({
    required this.name,
    this.icon,
    this.isGroup,
    this.time = '',
    this.currentMessage = '',
    required this.status,
    this.select = false,
    this.id,
  });
}

class CustomCard extends StatelessWidget {
  final ChatModel chatModel;
  final ChatModel? sourchat;
  final String imageUrl;
  final String roomId;

  const CustomCard({
    Key? key,
    required this.chatModel,
    required this.imageUrl,
    required this.roomId,
    this.sourchat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('ini room id $roomId');
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueGrey,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.network(imageUrl),
            ),
          ),
          title: Text(
            chatModel.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(roomId)
                    .collection('messages')
                    .orderBy('updatedAt', descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (context, snapshot) {
                  print('mobile room id ${roomId}');

                  if (snapshot.data?.docs.length == 0) {
                    return const SizedBox();
                  }
                  return Text(
                    ChatUtilUsecase.getDisplayMessage(
                      (snapshot.data?.docs.last.data() as Map),
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(roomId)
                    .collection('messages')
                    .orderBy('updatedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  print('mobile room id ${roomId}');
                  if (snapshot.data?.docs.length == 0) {
                    return const SizedBox();
                  }
                  final count = ChatUtilUsecase.getUnreadCount(
                    snapshot.data!.docs,
                  );
                  if(count == '0'){
                    return const SizedBox();
                  }
                  return Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.green),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        count,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          trailing: Text(chatModel.time),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 20, left: 80),
          child: Divider(
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
