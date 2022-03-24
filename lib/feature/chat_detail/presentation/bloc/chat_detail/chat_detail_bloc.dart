import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:simple_flutter/feature/chat_detail/domain/usecase/chat_detail_usecase.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/bloc/chat_loading_indicator/chat_loading_bloc.dart';

part 'chat_detail_event.dart';

part 'chat_detail_state.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final ChatDetailUsecase chatDetailUsecase;
  StreamSubscription? chatStream;
  final ChatLoadingBloc chatLoadingBloc;

  ChatDetailBloc({
    required this.chatDetailUsecase,
    required this.chatLoadingBloc,
  }) : super(ChatDetailInitial()) {
    on<ChatDetailEvent>((event, emit) {
      log("event name" + event.toString());
    });

    on<ChatSendMessageEvent>(
      (event, emit) {
        log("bloc run");
        chatDetailUsecase.sendTextMsg(
            partialText: event.message,
            roomId: event.room,
            replayRefId: event.replayRef,
            replayType: event.replayType,
            replayContent: event.replayContent,
            replayToAuthorName: event.replayToAuthor);
      },
    );

    on<ChatDetailInitStreamEvent>(
      (event, emit) {
        add(const ChatDetailDisplayMessageEvent(listMessage: [], isLoading: false));
        if (chatStream != null) {
          chatStream!.cancel();
          chatStream = null;
          print("sub empty");
        }
        final meUser = FirebaseAuth.instance.currentUser;
        chatStream =
            chatDetailUsecase.initStream(event.room).listen((messages) {
          messages.forEach(
            (element) {
              if (element.status != types.Status.seen &&
                  element.author.id != meUser!.uid) {
                print("change status");
                chatDetailUsecase.markAsRead(
                    message: element, room: event.room);
              }
              // else if (element.author.id == meUser!.uid &&
              //     element.status != types.Status.seen) {
              //   chatDetailUsecase.markAsDelivered(
              //       message: element, room: event.room);
              // }
            },
          );
          add(ChatDetailDisplayMessageEvent(listMessage: messages, isLoading: false));
        });
      },
    );

    on<ChatDetailDisposeEvent>(
      (event, emit) {
        if (chatStream != null) {
          chatStream!.cancel();
          chatStream = null;
          print("sub empty");
        }
        print("dispose message");
      },
    );

    on<ChatDetailDisplayMessageEvent>(
      (event, emit) {
        print("display message");
        emit(ChatDetailLoadingState());
        emit(
          ChatDetailLoadedState(
            listMessage: event.listMessage,
            isLoading: event.isLoading,
          ),
        );
      },
    );

    on<ChatDetailDeleteEvent>(
      (event, emit) {
        chatDetailUsecase.deleteMessage(
            message: event.message, room: event.room);
      },
    );

    on<ChatMarkAsReadEvent>(
      (event, emit) {
        chatDetailUsecase.markAsRead(
          message: event.message,
          room: event.room,
        );
      },
    );

    on<ChatDetailNextPageEvent>(
      (event, emit) {
        chatDetailUsecase.nextPage();
      },
    );

    on<ChatDetailSendImageEvent>(
      (event, emit) async {
        try {
          chatLoadingBloc.add(const ChatLoadingSetDataEvent(isLoading: true));

          await chatDetailUsecase.sendImageMsg(
            path: event.filePath,
            room: event.room,
            fileName: event.fileName,
          );
          chatLoadingBloc.add(const ChatLoadingSetDataEvent(isLoading: false));
        } catch (e) {
          log(e.toString());
        }
      },
    );
  }
}
