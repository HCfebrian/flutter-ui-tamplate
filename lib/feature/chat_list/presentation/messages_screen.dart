import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:simple_flutter/feature/chat_detail/widget/custom_card.dart';
import 'package:simple_flutter/utils/route_generator.dart';

class MessagesList extends StatelessWidget {
  const MessagesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<ChatModel> contacts = [
      ChatModel(name: 'Dev Stack', status: 'A full stack developer'),
      ChatModel(name: 'Balram', status: 'Flutter Developer...........'),
      ChatModel(name: 'Saket', status: 'Web developer...'),
      ChatModel(name: 'Bhanu Dev', status: 'App developer....'),
      ChatModel(name: 'Collins', status: 'Raect developer..'),
      ChatModel(name: 'Kishor', status: 'Full Stack Web'),
      ChatModel(name: 'Testing1', status: 'Example work'),
      ChatModel(name: 'Testing2', status: 'Sharing is caring'),
      ChatModel(name: 'Divyanshu', status: '.....'),
      ChatModel(name: 'Helper', status: 'Love you Mom Dad'),
      ChatModel(name: 'Tester', status: 'I find the bugs'),
    ];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Chat'),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () {
              log('onTap ${contacts[i].name}');
              Navigator.pushNamed(context, AppRoute.detailChat);
            },
            child: CustomCard(
              chatModel: contacts[i],
            ),
          );
        },
      ),
    );
  }
}
