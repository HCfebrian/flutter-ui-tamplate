import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/user/user_bloc.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/user/user_bloc.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/widget/custom_card.dart';
import 'package:simple_flutter/feature/chat_list/domain/entity/contact_entity.dart';
import 'package:simple_flutter/feature/chat_list/domain/usecase/contact_list_usecase.dart';
import 'package:simple_flutter/utils/route_generator.dart';

import '../../../get_it.dart';

class MessagesList extends StatefulWidget {
  const MessagesList({Key? key}) : super(key: key);

  @override
  State<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  final ContactListUsecase contactListUsecase = getIt();

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
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          return StreamBuilder<List<ContactEntity>>(
            stream: contactListUsecase.fetchContacts(
              userId: (state as UserLoggedInState).userEntity.id,
            ),
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data?.length ?? 0,
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
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          );
        },
      ),
    );
  }
}
