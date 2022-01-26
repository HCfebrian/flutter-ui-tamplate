import 'dart:async';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:simple_flutter/feature/chat_detail/domain/contract_repo/chat_detail_repo_abs.dart';

class ChatDetailRepoImpl implements ChatDetailRepoAbs {
  StreamController<List<types.Message>>? messageStream;

  @override
  Stream<List<types.Message>> initStream(types.Room room) {
    messageStream?.close();
    messageStream = null;
    messageStream ??= StreamController();
    FirebaseChatCore.instance.messages(room).listen((event) {
      messageStream!.add(event);
    });
    return messageStream!.stream;
  }

  @override
  void dispose() {}
}
