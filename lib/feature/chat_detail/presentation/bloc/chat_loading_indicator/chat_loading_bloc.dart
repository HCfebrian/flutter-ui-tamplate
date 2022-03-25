import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:simple_flutter/feature/chat_detail/domain/usecase/chat_detail_usecase.dart';

part 'chat_loading_event.dart';

part 'chat_loading_state.dart';

class ChatLoadingBloc extends Bloc<ChatLoadingEvent, ChatLoadingState> {
  final ChatDetailUsecase chatUsecase;

  ChatLoadingBloc({required this.chatUsecase}) : super(ChatLoadingInitial()) {
    on<ChatLoadingUploadImageEvent>((event, emit) async {
      emit(ChatLoadingTransformState());
      emit(ChatLoadingProcessState());
      final uri = await chatUsecase.uploadImage(
        path: event.pathImage,
        fileName: event.fileName,
      );
      await chatUsecase.sendImageMsg(uri: uri,
          path: event.pathImage,
          fileName: event.fileName,
          room: event.room);
      emit(ChatLoadingInitial());
      log("loading state now " + state.toString());
    });
  }
}
