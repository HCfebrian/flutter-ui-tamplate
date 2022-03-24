import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'chat_loading_event.dart';
part 'chat_loading_state.dart';

class ChatLoadingBloc extends Bloc<ChatLoadingEvent, ChatLoadingState> {
  ChatLoadingBloc() : super(ChatLoadingInitial()) {
    on<ChatLoadingSetDataEvent>((event, emit) {
      emit(ChatLoadingTransformState());
      if (event.isLoading) {
        log("loading state");
        emit(ChatLoadingProcessState());
      } else {
        log("loading state over");
        emit(ChatLoadingInitial());
      }
      log("loading state now "+ state.toString());
    });
  }
}
