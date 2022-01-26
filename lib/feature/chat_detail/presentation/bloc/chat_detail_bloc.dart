import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:simple_flutter/feature/chat_detail/domain/usecase/chat_detail_usecase.dart';

part 'chat_detail_event.dart';

part 'chat_detail_state.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final ChatDetailUsecase chatDetailUsecase;
  StreamSubscription? subscription;

  ChatDetailBloc({required this.chatDetailUsecase})
      : super(ChatDetailInitial()) {
    on<ChatDetailInitStreamEvent>(
      (event, emit) {
        add(ChatDetailDisplayMessageEvent(listMessage: []));
        if (subscription != null) {
          subscription!.cancel();
          subscription = null;
          print("sub empty");
        }
        subscription = chatDetailUsecase.initStream(event.room).listen((event) {
          add(ChatDetailDisplayMessageEvent(listMessage: event));
        });
      },
    );

    on<ChatDetailDisposeEvent>(
      (event, emit) {
        print("dispose message");
      },
    );

    on<ChatDetailDisplayMessageEvent>(
      (event, emit) {
        print("display message");
        emit(ChatDetailLoadingState());
        emit(ChatDetailLoadedState(listMessage: event.listMessage));
      },
    );
  }
}
