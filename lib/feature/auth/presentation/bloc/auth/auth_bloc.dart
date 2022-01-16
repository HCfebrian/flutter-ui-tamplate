import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:simple_flutter/feature/auth/domain/usecase/auth_usecase.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUsecase authUsecase;

  AuthBloc({required this.authUsecase}) : super(AuthInitial()) {
    on<AuthLoginEvent>(
      (event, emit) {
        authUsecase.loginUser(email: event.email, password: event.password);
      },
    );

    on<AuthRegisterEvent>((event, emit) async {
      emit(AuthLoadingState());
      if (event.password == event.rePassword) {
        await authUsecase.registerUser(
          email: event.email,
          password: event.password,
        );
        emit(AuthFinished());
      } else {
        emit(const AuthErrorState(message: 'Password did not match'));
      }
    });

    on<AuthCancelRequestEvent>((event, emit) {
      emit(AuthInitial());
      authUsecase.cancelRequest();
    });


    on<AuthLoginWithGoogleEvent>((event, emit) async{
      emit(AuthInitial());
      await authUsecase.loginWithGoogle();
      emit(AuthFinished());
      log("authFinished");
    });
  }
}
