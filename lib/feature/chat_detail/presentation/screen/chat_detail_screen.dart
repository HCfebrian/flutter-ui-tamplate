import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
import 'package:simple_flutter/feature/chat_detail/presentation/bloc/chat_detail_bloc.dart';

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatDetail extends StatefulWidget {
  final types.Room? room;

  const ChatDetail({Key? key, this.room}) : super(key: key);

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final List<types.Message> _messages = [];
  bool _isAttachmentUploading = false;

  final int _page = 0;

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

        FirebaseChatCore.instance.sendMessage(message, widget.room!.id);
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

  void _handleSendPressed(types.PartialText message) {
    FirebaseChatCore.instance.sendMessage(
      message,
      widget.room!.id,
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
          widget.room!.id,
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

  // Future<void> _handleEndReached() async {
  //   final uri = Uri.parse(
  //     'https://api.instantwebtools.net/v1/passenger?page=$_page&size=20',
  //   );
  //   final response = await http.get(uri);
  //   final json = jsonDecode(response.body) as Map<String, dynamic>;
  //   final data_source = json['data_source'] as List<dynamic>;
  //   print(data_source);
  //   final messages = data_source
  //       .map(
  //         (e) => types.TextMessage(
  //           author: _user,
  //           id: e['_id'] as String,
  //           text: e['airline'].toString(),
  //         ),
  //       )
  //       .toList();
  //   setState(() {
  //     _messages = [..._messages, ...messages];
  //     _page = _page + 1;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    print('init dong');
    BlocProvider.of<ChatDetailBloc>(context).add(ChatDetailInitStreamEvent(widget.room!));
    // _handleEndReached();
  }

  @override
  void dispose() {
    print('should be dispose');
    BlocProvider.of<ChatDetailBloc>(context).add(ChatDetailDisposeEvent());
    print('should be dispose dong');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: StreamBuilder<types.Room>(
        initialData: widget.room,
        // stream: FirebaseChatCore.instance.room(widget.room!.id),
        builder: (context, snapshot) {
          return StreamBuilder<List<types.Message>>(
            initialData: const [],
            // stream: FirebaseChatCore.instance.messages(snapshot.data!),
            builder: (context, snapshot) {
              return BlocBuilder<ChatDetailBloc, ChatDetailState>(
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
                        isAttachmentUploading: _isAttachmentUploading,
                        messages: state.listMessage,
                        onAttachmentPressed: _handleAtachmentPressed,
                        onMessageTap: _handleMessageTap,
                        onPreviewDataFetched: _handlePreviewDataFetched,
                        onSendPressed: _handleSendPressed,
                        user: types.User(
                          id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
                        ),
                      ),
                    );
                  }
                  return Container();
                },
              );
            },
          );
        },
      ),
    );
  }
}
