import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';
import 'package:simple_flutter/feature/auth/domain/usecase/auth_usecase.dart';
import 'package:simple_flutter/feature/auth/domain/usecase/user_usecase.dart';

part 'user_event.dart';

part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserUsecase userUsecase;
  final AuthUsecase authUsecase;

  UserBloc({
    required this.userUsecase,
    required this.authUsecase,
  }) : super(UserInitial()) {
    on<UserGetDataEvent>(
      (event, emit) async {
        emit(UserLoadingState());
        final UserEntity user = await userUsecase.getUserData();
        emit(UserLoggedInState(userEntity: user));
      },
    );

    on<UserLoggedOutEvent>((event, emit) async {
      emit(UserLoadingState());
      await authUsecase.logout();
      emit(UserLoggedOutState());
    });
  }
}
