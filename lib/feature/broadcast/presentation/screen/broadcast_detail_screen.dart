import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/user/user_bloc.dart';
import 'package:simple_flutter/feature/broadcast/presentation/bloc/broadcast_bloc.dart';
import 'package:simple_flutter/feature/broadcast/presentation/screen/broadcast_list_user_screen.dart';
import 'package:simple_flutter/feature/contact_list/presentation/users.dart';

class BroadcastDetailScreen extends StatefulWidget {
  final List<String> listUserBroadcast;

  const BroadcastDetailScreen({
    required this.listUserBroadcast,
    Key? key,
  }) : super(key: key);

  @override
  State<BroadcastDetailScreen> createState() => _BroadcastDetailScreenState();
}

class _BroadcastDetailScreenState extends State<BroadcastDetailScreen> {
  String? myUserId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoggedOutState) {
          myUserId = null;
        }
        if (state is UserLoggedInState) {
          myUserId = state.userEntity.id;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Broadcast Message'),
          actions: [
            GestureDetector(
              child: const Icon(Icons.people_outline_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BroadcastListUserScreen(),
                  ),
                );
              },
            ),
            const SizedBox(
              width: 20,
            )
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Chat(
            emptyState: StreamBuilder<List<types.User>>(
              stream: FirebaseChatCore.instance.users(),
              initialData: const [],
              builder: (context, snapshot) {
                List<types.User> userList = [];

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(
                      bottom: 200,
                    ),
                    child: const Text('No users'),
                  );
                }
                snapshot.data!.forEach((element) {
                  if (widget.listUserBroadcast.contains(element.id)) {
                    userList.add(element);
                  }
                });

                return ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, index) {
                    final user = userList[index];
                    return ContactTileWidget(
                      myUserId: myUserId,
                      otherUser: user,
                      isBroadcast: false,
                    );
                  },
                );
              },
            ),
            user: types.User(
              id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
            ),
            onSendPressed: (types.PartialText message) {
              try {
                log("send messages " + message.text);
                BlocProvider.of<BroadcastBloc>(context).add(
                  BroadcastSendMessageEvent(
                    listUserId: listUserBroadcastId,
                    messages: message,
                  ),
                );
              } catch (e) {
                log(e.toString());
              }
            },
            messages: [],
          ),
        ),
      ),
    );
  }
}
