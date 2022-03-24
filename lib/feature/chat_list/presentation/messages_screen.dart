import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/user/user_bloc.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/widget/custom_card.dart';
import 'package:simple_flutter/feature/chat_list/presentation/bloc/chat_list_bloc.dart';
import 'package:simple_flutter/feature/contact_list/presentation/users.dart';
import 'package:simple_flutter/utils/route_generator.dart';

class MessagesList extends StatefulWidget {
  const MessagesList({Key? key}) : super(key: key);

  @override
  State<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  UserEntity? myUserEntity;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      log('check permission');
      if (!isAllowed) {
        log('check permission failed');
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Izinkan Aplikasi untuk menampilkan Notifikasi?"),
            actions: [
              GestureDetector(
                child: Text("Tidak"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              GestureDetector(
                child: Text("OK"),
                onTap: () {
                  AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then(
                        (value) => Navigator.pop(context),
                      );
                },
              )
            ],
          ),
        );
      } else {
        log("check permission success");
      }
    });
    return WillPopScope(
      onWillPop: () async => false,
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoggedInState) {
            log('current user ${state.userEntity.firstName}');
            myUserEntity = state.userEntity;
          }
          if (state is UserLoggedOutState) {
            myUserEntity = null;
          }
          return Scaffold(
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
                    if (snapshot.data?[i].metadata?[
                            'isDeleted-${FirebaseAuth.instance.currentUser!.uid}'] ==
                        true) {
                      return const SizedBox();
                    }
                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            insetPadding: const EdgeInsets.all(20),
                            title: const Text('Delete message locally?'),
                            actions: [
                              GestureDetector(
                                child: const Text('delete'),
                                onTap: () {
                                  BlocProvider.of<ChatListBloc>(context).add(
                                    ChatListDeleteRoomEvent(
                                      room: snapshot.data![i],
                                    ),
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                              GestureDetector(
                                child: const Text('close'),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      onTap: () {
                        log('onTap ${snapshot.data?[i].name}');

                        Navigator.pushNamed(context, AppRoute.detailChat,
                            arguments: {
                              "name": snapshot.data![i].name,
                              "room": snapshot.data![i],
                              "myUserId": myUserEntity?.id,
                              "myUsername": myUserEntity?.firstName
                            });
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
          );
        },
      ),
    );
  }
}
