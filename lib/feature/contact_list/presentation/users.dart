import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/user/user_bloc.dart';
import 'package:simple_flutter/utils/background_utils.dart';
import 'package:simple_flutter/utils/route_generator.dart';

List<String> listUserBroadcastId = [];

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String? myUserId;
  bool isBroadcast = false;

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
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: const Text('Users'),
          actions: [
            if (isBroadcast)
              GestureDetector(
                child: const Icon(Icons.person),
                onTap: () {
                  log('message 1');
                  isBroadcast = !isBroadcast;
                  setState(() {});
                },
              )
            else
              GestureDetector(
                child: const Icon(Icons.settings_input_antenna),
                onTap: () {
                  log('message 2');
                  isBroadcast = !isBroadcast;
                  setState(() {});
                },
              ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
        body: StreamBuilder<List<types.User>>(
          stream: FirebaseChatCore.instance.users(),
          initialData: const [],
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(
                  bottom: 200,
                ),
                child: const Text('No users'),
              );
            }

            return Stack(
              children: [
                ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final user = snapshot.data![index];
                    return ContactTileWidget(
                      myUserId: myUserId,
                      otherUser: user,
                      isBroadcast: isBroadcast,
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.blue,
                    child: isBroadcast
                        ? GestureDetector(
                            onTap: () {
                              log(listUserBroadcastId.length.toString());
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  'Broadcast',
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class ContactTileWidget extends StatefulWidget {
  final types.User otherUser;
  final String? myUserId;
  final bool isBroadcast;

  const ContactTileWidget({
    Key? key,
    required this.otherUser,
    required this.myUserId,
    required this.isBroadcast,
  }) : super(key: key);

  @override
  State<ContactTileWidget> createState() => _ContactTileWidgetState();
}

class _ContactTileWidgetState extends State<ContactTileWidget> {
  bool isChecked = false;

  Future<void> _handlePressed(
      types.User otherUser, BuildContext context) async {
    final room = await FirebaseChatCore.instance.createRoom(otherUser);
    FirebaseChatCore.instance.updateRoom(
      room.copyWith(metadata: {
        'isDeleted-${FirebaseAuth.instance.currentUser!.uid}': false,
      }),
    );
    log('other user ${otherUser.firstName}');
    Navigator.of(context).pop();
    Navigator.pushNamed(
      context,
      AppRoute.detailChat,
      arguments: {
        'name': otherUser.firstName,
        'room': room,
        'myUserId': widget.myUserId
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.isBroadcast) _handlePressed(widget.otherUser, context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Row(
          children: [
            BuildAvatarWidget(user: widget.otherUser),
            Text(
              getUserName(widget.otherUser),
            ),
            if (widget.isBroadcast)
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      isChecked = !isChecked;
                      if (isChecked) {
                        listUserBroadcastId.add(widget.otherUser.id);
                        log(listUserBroadcastId.length.toString());
                      } else {
                        listUserBroadcastId.remove(widget.otherUser.id);
                        log(listUserBroadcastId.length.toString());
                      }
                      setState(() {});
                    },
                  ),
                ),
              )
            else
              const SizedBox()
          ],
        ),
      ),
    );
  }
}

class BuildAvatarWidget extends StatefulWidget {
  final types.User user;

  const BuildAvatarWidget({Key? key, required this.user}) : super(key: key);

  @override
  State<BuildAvatarWidget> createState() => _BuildAvatarWidgetState();
}

class _BuildAvatarWidgetState extends State<BuildAvatarWidget> {
  @override
  Widget build(BuildContext context) {
    final color = getUserAvatarNameColor(widget.user);
    final hasImage = widget.user.imageUrl != null;
    final name = getUserName(widget.user);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(widget.user.imageUrl!) : null,
        radius: 20,
        child: !hasImage
            ? Text(
                name.isEmpty ? '' : name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
    );
  }
}
