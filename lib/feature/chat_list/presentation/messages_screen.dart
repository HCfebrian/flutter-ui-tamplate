import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/screen/chat_detail_screen.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/widget/custom_card.dart';
import 'package:simple_flutter/feature/contact_list/presentation/users.dart';

class MessagesList extends StatelessWidget {
  const MessagesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => const UsersPage(),
              ),
            );
          },
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Chat'),
          actions: [
            IconButton(
              onPressed: () {
                BlocProvider.of<AuthBloc>(context).add(AuthLogoutEvent());
              },
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: StreamBuilder<List<types.Room>>(
          stream: FirebaseChatCore.instance.rooms(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(
                  bottom: 200,
                ),
                child: const Text('No messages'),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () {
                    log('onTap ${snapshot.data?[i].name}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetail(
                          room: snapshot.data![i],
                        ),
                      ),
                    );
                  },
                  child: CustomCard(
                    imageUrl: snapshot.data?[i].imageUrl ?? '',
                    chatModel: ChatModel(
                      name: snapshot.data![i].name ?? '',
                      status: snapshot.data![i].lastMessages?.last.status
                              .toString() ??
                          '',
                    ),
                    roomId: snapshot.data![i].id,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
