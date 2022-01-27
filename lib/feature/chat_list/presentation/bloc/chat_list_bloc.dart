import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:simple_flutter/feature/chat_list/domain/usecase/chat_usecase.dart';

part 'chat_list_event.dart';

part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatUsecase chatUsecase;

  ChatListBloc({required this.chatUsecase}) : super(ChatListInitial()) {
    on<ChatListStartStreamEvent>((event, emit) {});

    on<ChatListDeleteRoomEvent>((event, emit) {
      chatUsecase.deleteRoom(event.room);
    });
  }
}
