import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:simple_flutter/core/color/chat_thame.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/user/user_bloc.dart';
import 'package:simple_flutter/feature/broadcast/presentation/bloc/broadcast_bloc.dart';
import 'package:simple_flutter/feature/chat_detail/domain/usecase/chat_detail_usecase.dart';
import 'package:simple_flutter/feature/chat_list/presentation/messages_screen.dart';
import 'package:simple_flutter/feature/contact_list/presentation/users.dart';
import 'package:simple_flutter/get_it.dart';

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
  bool _isAttachmentUploading = false;

  Future<void> _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.camera,
    );
    _setAttachmentUploading(true);
    log('file name ${result?.name}');
    final ChatDetailUsecase chatUsecase = getIt();
    final uri = await chatUsecase.uploadImage(
      path: result!.path,
      fileName: result.name,
    );

    final file = File(result.path);
    final size = file.lengthSync();
    final bytes = await file.readAsBytes();
    final image = await decodeImageFromList(bytes);

    final message = types.PartialImage(
      height: image.height.toDouble(),
      name: result.name,
      size: size,
      uri: uri,
      width: image.width.toDouble(),
    );

    BlocProvider.of<BroadcastBloc>(context).add(
      BroadcastSendImageMessageEvent(
          messages: message, listUserId: listUserBroadcastId),
    );
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  Future<void> _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      _setAttachmentUploading(true);
      final name = result.files.single.name;
      final filePath = result.files.single.path!;
      final file = File(filePath);

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialFile(
          mimeType: lookupMimeType(filePath),
          name: name,
          size: result.files.single.size,
          uri: uri,
        );

        BlocProvider.of<BroadcastBloc>(context)
            .add(BroadcastSendFileMessageEvent(
          listUserId: listUserBroadcastId,
          messages: message,
        ));
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleImageSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Photo'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleFileSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('File'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log("build");
    return BlocListener<BroadcastBloc, BroadcastState>(
      listener: (context, state) {
        if (state is BroadcastLoadingState) {
          // showAboutDialog(context: (context) => CircularProgressIndicator());
          showDialog(
            context: context,
            builder: (context) => GestureDetector(
              child: const CircularProgressIndicator(),
            ),
          );
        }
        if (state is BroadcastSuccessState) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MessagesList()),
              (route) => false);
        }
      },
      child: BlocListener<UserBloc, UserState>(
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
            backgroundColor: ChatThemeCustom.getBarColor(),
            title: Text(
              'Broadcast Message to',
              style: TextStyle(
                color: ChatThemeCustom.barContentColor,
              ),
            ),
            actions: [
              // GestureDetector(
              //   child: const Icon(Icons.people_outline_rounded),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const BroadcastListUserScreen(),
              //       ),
              //     );
              //   },
              // ),
              // const SizedBox(
              //   width: 20,
              // )
            ],
          ),
          body: SafeArea(
            bottom: false,
            child: Chat(
              isAttachmentUploading: _isAttachmentUploading,
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
              onAttachmentPressed: _handleAtachmentPressed,
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
      ),
    );
  }
}
