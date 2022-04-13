import 'dart:developer';
import 'dart:io';

import 'package:bubble/bubble.dart';
import 'package:file_picker/file_picker.dart';
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
import 'package:simple_flutter/core/color/chat_thame.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/user/user_bloc.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/bloc/chat_detail/chat_detail_bloc.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/bloc/chat_detail_status/chat_detail_status_bloc.dart';
import 'package:swipe_to/swipe_to.dart';

import '../bloc/chat_loading_indicator/chat_loading_bloc.dart';

class ChatDetail extends StatefulWidget {
  final types.Room room;
  final String name;
  final String myUserId;
  final String myUsername;

  const ChatDetail({
    Key? key,
    required this.room,
    required this.name,
    required this.myUserId,
    required this.myUsername,
  }) : super(key: key);

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final List<types.Message> _messages = [];
  bool _isAttachmentUploading = false;
  bool isBounch = false;
  late ChatDetailBloc chatDetailBloc;
  types.Message? replayMessage;
  Color appBarColor = ChatThemeCustom.barColor;

  Future _handleOnReachEnd() async {
    BlocProvider.of<ChatDetailBloc>(context).add(ChatDetailNextPageEvent());
  }

  Widget _bubbleBuilder(
    Widget child, {
    required message,
    required nextMessageInGroup,
  }) {
    return SwipeTo(
      onRightSwipe: () {
        replayMessage = message as types.Message;
        setState(() {});
      },
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoggedInState) {
            return Align(
              alignment: state.userEntity.id == message.author.id
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Bubble(
                  color: state.userEntity.id != message.author.id
                      ? ChatThemeCustom.peopleBubbleColor
                      : ChatThemeCustom.myBubbleColor,
                  margin: const BubbleEdges.symmetric(horizontal: 0),
                  nip: state.userEntity.id != message.author.id
                      ? BubbleNip.leftBottom
                      : BubbleNip.rightBottom,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.metadata?['replayTo'] != null)
                        Container(
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                            left: 5,
                            right: 5,
                          ),
                          color: Colors.black26,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Text(
                                  "${message.metadata?['replayToAuthorName']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              if (message.metadata?['replayType'] == "text")
                                Text("${message.metadata?['replayContent']}"),
                              if (message.metadata?['replayType'] == "file")
                                Text("${message.metadata?['replayContent']}"),
                              if (message.metadata?['replayType'] == "image")
                                Image.network(
                                  "${message.metadata?['replayContent']}",
                                  scale: 10,
                                )
                            ],
                          ),
                        )
                      else
                        const SizedBox(),
                      child,
                    ],
                  )),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Future<void> _handleMessageTap(
      BuildContext context, types.Message message) async {
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

  Future<void> _handleLongPress(
      BuildContext context, types.Message message) async {
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

  Future<void> _handleSendPressed(types.PartialText message) async {
    log("handlesendpress");
    log("message ${message.toJson()}");
    log("room ${widget.room.id}");
    log("message type ${replayMessage?.type.name.toString()}");
    String? replayContent;
    String? replayToAuthorName;
    if (replayMessage?.type.name == "text") {
      replayContent = (replayMessage as types.TextMessage).text;
      if (widget.myUserId == (replayMessage as types.TextMessage).author.id) {
        replayToAuthorName = widget.myUsername;
      } else {
        replayToAuthorName = widget.name;
      }
    } else if (replayMessage?.type.name == "image") {
      replayContent = (replayMessage as types.ImageMessage).uri;
      if (widget.myUserId == (replayMessage as types.ImageMessage).author.id) {
        replayToAuthorName = widget.myUsername;
      } else {
        replayToAuthorName = widget.name;
      }
    } else if (replayMessage?.type.name == "file") {
      try {
        replayContent = (replayMessage as types.FileMessage).name;
        if (widget.myUserId == (replayMessage as types.FileMessage).author.id) {
          replayToAuthorName = widget.myUsername;
        } else {
          replayToAuthorName = widget.name;
        }
      } catch (e) {
        log(e.toString());
      }
    }
    BlocProvider.of<ChatDetailBloc>(context).add(
      ChatSendMessageEvent(
          message: message,
          room: widget.room,
          replayRef: replayMessage?.id,
          replayType: replayMessage?.type.name,
          replayContent: replayContent,
          replayToAuthor: replayToAuthorName),
    );
    replayMessage = null;
    setState(() {});
  }

  Future<void> _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.camera,
    );
    log('file name ${result?.name}');

    if (result != null) {
      BlocProvider.of<ChatLoadingBloc>(context).add(ChatLoadingUploadImageEvent(
          pathImage: result.path, fileName: result.name, room: widget.room));
      // BlocProvider.of<ChatDetailBloc>(context).add(
      //   ChatDetailSendImageEvent(
      //     filePath: result.path,
      //     room: widget.room,
      //     fileName: result.name,
      //   ),
      // );
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

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: Icon(Icons.arrow_back, color: ChatThemeCustom.barContentColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatLoadingBloc, ChatLoadingState>(
      listener: (context, state) {
        if (state is ChatLoadingProcessState) {
          _setAttachmentUploading(true);
        } else {
          _setAttachmentUploading(false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: _backButton(),
          automaticallyImplyLeading: false,
          backgroundColor: ChatThemeCustom.getBarColor(),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: TextStyle(color: ChatThemeCustom.barContentColor),
              ),
              BlocBuilder<ChatDetailStatusBloc, ChatDetailStatusState>(
                builder: (context, state) {
                  if (state is ChatDetailCurrentStatus) {
                    if (state.chatStatus == ChatStatus.typing) {
                      return const Text(
                        'Typing...',
                        style: TextStyle(fontSize: 10),
                      );
                    }
                    if (state.chatStatus == ChatStatus.online) {
                      return const Text(
                        'online',
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
                  customBottomWidget: _buildCustomTextInput(),
                  bubbleBuilder: _bubbleBuilder,
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
      ),
    );
  }

  Column _buildCustomTextInput() {
    return Column(
      children: [
        ReplayWidget(
          message: replayMessage,
          close: () {
            replayMessage = null;
            setState(() {});
          },
        ),
        Container(
          color: replayMessage != null ? Colors.black26 : null,
          child: Input(
            isAttachmentUploading: _isAttachmentUploading,
            onAttachmentPressed: _handleAtachmentPressed,
            onSendPressed: _handleSendPressed,
            onTextChanged: _handleOnTextChange,
            sendButtonVisibilityMode: SendButtonVisibilityMode.always,
          ),
        ),
      ],
    );
  }
}

class ReplayWidget extends StatelessWidget {
  final types.Message? message;
  final Function close;

  const ReplayWidget({
    Key? key,
    this.message,
    required this.close,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message != null) {
      if (message is types.TextMessage) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text((message! as types.TextMessage).text),
              GestureDetector(
                child: const Icon(Icons.close),
                onTap: () {
                  close();
                },
              ),
            ],
          ),
        );
      } else if (message is types.FileMessage) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text((message! as types.FileMessage).name),
              GestureDetector(
                child: const Icon(Icons.close),
                onTap: () {
                  close();
                },
              ),
            ],
          ),
        );
      } else if (message is types.ImageMessage) {
        return Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.network(
                (message! as types.ImageMessage).uri,
                height: 60,
              ),
              GestureDetector(
                child: const Icon(Icons.close),
                onTap: () {
                  close();
                },
              ),
            ],
          ),
        );
      } else {
        return Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("message"),
              GestureDetector(
                child: const Icon(Icons.close),
                onTap: () {
                  close();
                },
              ),
            ],
          ),
        );
      }
    } else {
      return const SizedBox();
    }
  }
}
