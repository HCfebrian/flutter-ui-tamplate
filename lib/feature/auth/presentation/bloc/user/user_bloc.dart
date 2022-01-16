import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:simple_flutter/core/shared_feature/chat_util/domain/usecase/chat_util_usecase.dart';
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';
import 'package:simple_flutter/feature/auth/domain/usecase/auth_usecase.dart';
import 'package:simple_flutter/feature/auth/domain/usecase/user_usecase.dart';

part 'user_event.dart';

part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserUsecase userUsecase;
  final AuthUsecase authUsecase;
  final ChatUtilUsecase chatUtilUsecase;

  UserBloc({
    required this.chatUtilUsecase,
    required this.userUsecase,
    required this.authUsecase,
  }) : super(UserInitial()) {
    on<UserGetDataEvent>(
      (event, emit) async {
        emit(UserLoadingState());
        final UserEntity? user = await userUsecase.getUserData();
        if (user != null) {
          log('user now $user');
          emit(UserLoggedInState(userEntity: user));
        } else {
          log('user loggout data $user');
          emit(UserLoggedOutState());
        }
      },
    );

    on<UserLoggedOutEvent>((event, emit) async {
      emit(UserLoadingState());
      await authUsecase.logout();
      emit(UserLoggedOutState());
    });
    on<UserStataeStreamInitEvent>(
      (event, emit) async {
        userUsecase.getUserDataStream().listen(
          (event) {
            add(_UserGetUpdatedEvent(event));
          },
        );
      },
    );

    on<_UserGetUpdatedEvent>((event, emit) async {
      if (event.userEntity != null) {
        log('user now dong ${event.userEntity?.name}');
        chatUtilUsecase.registerUserChat(userEntity: event.userEntity!);
        emit(UserLoggedInState(userEntity: event.userEntity!));
      } else {
        emit(UserLoggedOutState());
      }
    });
  }
}
