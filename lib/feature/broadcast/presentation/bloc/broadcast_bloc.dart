import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:simple_flutter/feature/broadcast/broadcast_usecase/broadcast_usecase.dart';

part 'broadcast_event.dart';

part 'broadcast_state.dart';

class BroadcastBloc extends Bloc<BroadcastEvent, BroadcastState> {
  final BroadcastUsecase broadcastUsecase;

  BroadcastBloc({required this.broadcastUsecase}) : super(BroadcastInitial()) {
    on<BroadcastEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<BroadcastSendMessageEvent>((event, emit) async {
      log("test broadcast");
      emit(BroadcastLoadingState());
      await broadcastUsecase.sendTextBroadcast(
        message: event.messages,
        listUserId: event.listUserId,
        myUserId: FirebaseAuth.instance.currentUser!.uid,
      );
      emit(BroadcastSuccessState());
    });
  }
}
