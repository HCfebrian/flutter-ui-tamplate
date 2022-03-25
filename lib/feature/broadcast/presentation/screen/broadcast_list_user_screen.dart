import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/user/user_bloc.dart';
import 'package:simple_flutter/feature/contact_list/presentation/users.dart';

class BroadcastListUserScreen extends StatefulWidget {
  const BroadcastListUserScreen({Key? key}) : super(key: key);

  @override
  State<BroadcastListUserScreen> createState() =>
      _BroadcastListUserScreenState();
}

class _BroadcastListUserScreenState extends State<BroadcastListUserScreen> {
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
          title: const Text("Broadcast To"),
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

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return ContactTileWidget(
                  myUserId: myUserId,
                  otherUser: user,
                  isBroadcast: false,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
