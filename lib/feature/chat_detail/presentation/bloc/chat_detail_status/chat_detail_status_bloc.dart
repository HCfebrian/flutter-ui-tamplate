import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:simple_flutter/feature/chat_detail/domain/usecase/chat_detail_usecase.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

part 'chat_detail_status_event.dart';

part 'chat_detail_status_state.dart';

class ChatDetailStatusBloc
    extends Bloc<ChatDetailStatusEvent, ChatDetailStatusState> {
  final ChatDetailUsecase chatDetailUsecase;

  ChatDetailStatusBloc({
    required this.chatDetailUsecase,
  }) : super(ChatDetailStatusInitial()) {
    on<ChatDetailStatusEvent>((event, emit) {});

    on<ChatDetailStatusStartStreamEvent>((event, emit) {
      List<types.User> users = event.room.users;
      users.removeWhere((element) => element.id == event.myUserId);
      if (users.length == 1) {
        final String otherUserId = users[0].id;
        chatDetailUsecase
            .statusStartStream(room: event.room, otherUserId: otherUserId)
            .listen((currentStatus) {
          add(ChatDetailShowStatusEvent(status: currentStatus));
        });
      }
    });

    on<ChatDetailChangeStatusTypingEvent>(
      (event, emit) {
        chatDetailUsecase.typingStatus(
          room: event.room,
          myUserId: event.myUserId,
        );
      },
    );

    on<ChatDetailShowStatusEvent>((event, emit) {
      emit(ChatDetailCurrentStatus(chatStatus: event.status));
    });
  }
}
