import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bubble/bubble.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/bloc/chat_detail/chat_detail_bloc.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/bloc/chat_detail_status/chat_detail_status_bloc.dart';

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatDetail extends StatefulWidget {
  final types.Room room;
  final String name;
  final String myUserId;

  const ChatDetail(
      {Key? key,
      required this.room,
      required this.name,
      required this.myUserId})
      : super(key: key);

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final List<types.Message> _messages = [];
  bool _isAttachmentUploading = false;
  bool isBounch = false;
  late ChatDetailBloc chatDetailBloc;

  final int _page = 0;

  Future _handleOnReachEnd() async {}

  Future<void> _handleMessageTap(types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        final client = http.Client();
        final request = await client.get(Uri.parse(message.uri));
        final bytes = request.bodyBytes;
        final documentsDir = (await getApplicationDocumentsDirectory()).path;
        localPath = '$documentsDir/${message.name}';

        if (!File(localPath).existsSync()) {
          final file = File(localPath);
          await file.writeAsBytes(bytes);
        }
      }

      await OpenFile.open(localPath);
    }
  }

  Future<void> _handleLongPress(types.Message message) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete message?'),
        actions: [
          GestureDetector(
            child: const Text('delete'),
            onTap: () {
              BlocProvider.of<ChatDetailBloc>(context).add(
                ChatDetailDeleteEvent(
                  message: message,
                  room: widget.room,
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
  }

  Future<void> _handleOnTextChange(
    String message,
  ) async {
    print("handle on change " + widget.room.toString());
    print("handle on change " + widget.myUserId.toString());
    BlocProvider.of<ChatDetailStatusBloc>(context).add(
      ChatDetailChangeStatusTypingEvent(
        chatStatus: ChatStatus.typing,
        room: widget.room,
        myUserId: widget.myUserId,
      ),
    );
  }

  Widget _bubbleBuilder(
    Widget child, {
    required message,
    required nextMessageInGroup,
  }) {
    return Bubble(
      child: Container(
        child: Text(message.toString()),
      ),
      color: FirebaseAuth.instance.currentUser!.uid.toString() !=
                  message.author.id.toString() ||
              message.type == types.MessageType.image
          ? const Color(0xfff5f5f7)
          : const Color(0xff6f61e8),
      // margin: nextMessageInGroup
      //     ? const BubbleEdges.symmetric(horizontal: 6)
      //     : null,
      // nip: nextMessageInGroup
      //     ? BubbleNip.no
      //     : _user.id != message.author.id
      //         ? BubbleNip.leftBottom
      //         : BubbleNip.rightBottom,
    );
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

        FirebaseChatCore.instance.sendMessage(message, widget.room.id);
        FirebaseChatCore.instance.updateRoom(
          widget.room.copyWith(metadata: {
            'isDeleted-${FirebaseAuth.instance.currentUser!.uid}': false
          }),
        );
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    FirebaseChatCore.instance.sendMessage(
      message,
      widget.room.id,
    );
    FirebaseChatCore.instance.updateRoom(
      widget.room.copyWith(metadata: {
        'isDeleted-${FirebaseAuth.instance.currentUser!.uid}': false
      }),
    );
  }

  Future<void> _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.camera,
    );

    if (result != null) {
      _setAttachmentUploading(true);
      final file = File(result.path);
      final size = file.lengthSync();
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.name;

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();
        print('uri $uri');
        final message = types.PartialImage(
          height: image.height.toDouble(),
          name: name,
          size: size,
          uri: uri,
          width: image.width.toDouble(),
        );

        FirebaseChatCore.instance.sendMessage(
          message,
          widget.room.id,
        );
        FirebaseChatCore.instance.updateRoom(
          widget.room.copyWith(metadata: {
            'isDeleted-${FirebaseAuth.instance.currentUser!.uid}': false
          }),
        );
        _setAttachmentUploading(false);
      } catch (e) {
        print('error image selection $e');
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = _messages[index].copyWith(previewData: previewData);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    print('init dong');
    chatDetailBloc = BlocProvider.of<ChatDetailBloc>(context);
    BlocProvider.of<ChatDetailBloc>(context)
        .add(ChatDetailInitStreamEvent(widget.room));
    BlocProvider.of<ChatDetailStatusBloc>(context).add(
      ChatDetailStatusStartStreamEvent(
        room: widget.room,
        myUserId: widget.myUserId,
      ),
    );
  }

  @override
  void dispose() {
    print('should be dispose');
    // BlocProvider.of<ChatDetailBloc>(context).add(ChatDetailInitStreamEvent(widget.room));
    chatDetailBloc.add(const ChatDetailDisposeEvent());
    print('should be dispose dong');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.name),
            BlocBuilder<ChatDetailStatusBloc, ChatDetailStatusState>(
              builder: (context, state) {
                if (state is ChatDetailCurrentStatus) {
                  if (state.chatStatus == ChatStatus.typing) {
                    return const Text(
                      'Typing...',
                      style: TextStyle(fontSize: 10),
                    );
                  }
                  if (state.chatStatus == ChatStatus.offline) {
                    return const SizedBox();
                  }
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<ChatDetailBloc, ChatDetailState>(
        builder: (context, state) {
          if (state is ChatDetailErrorState) {
            return const Expanded(
              child: Center(
                child: Text('Error'),
              ),
            );
          }
          if (state is ChatDetailLoadingState) {
            print('show loading state');
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is ChatDetailLoadedState) {
            return SafeArea(
              bottom: false,
              child: Chat(
                // bubbleBuilder: _bubbleBuilder,
                isAttachmentUploading: _isAttachmentUploading,
                messages: state.listMessage,
                onAttachmentPressed: _handleAtachmentPressed,
                onMessageTap: _handleMessageTap,
                onPreviewDataFetched: _handlePreviewDataFetched,
                onSendPressed: _handleSendPressed,
                onMessageLongPress: _handleLongPress,
                onTextChanged: _handleOnTextChange,
                onEndReached: _handleOnReachEnd,
                user: types.User(
                  id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
                ),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
