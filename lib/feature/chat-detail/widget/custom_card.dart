import 'package:flutter/material.dart';

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
    this.time = "",
    this.currentMessage = "",
    required this.status,
    this.select = false,
    this.id,
  });
}

class CustomCard extends StatelessWidget {
  final ChatModel chatModel;
  final ChatModel? sourchat;

  const CustomCard({Key? key, required this.chatModel, this.sourchat})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 30,
            child: Icon(Icons.person),
            backgroundColor: Colors.blueGrey,
          ),
          title: Text(
            chatModel.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(Icons.done_all),
              SizedBox(
                width: 3,
              ),
              Text(
                chatModel.status,
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ),
          trailing: Text(chatModel.time),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20, left: 80),
          child: Divider(
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
