import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:simple_flutter/feature/splash_screen/domain/usecase/splash_usecase.dart';

part 'splashscreen_event.dart';

part 'splashscreen_state.dart';

class SplashScreenBloc extends Bloc<SplashscreenEvent, SplashScreenState> {
  final SplashUsecase splashUsecase;

  SplashScreenBloc({required this.splashUsecase}) : super(SplashInitState()) {
    on<SplashScreenInitEvent>(
      (event, emit) async {
        await splashUsecase.initApp();
        return emit(
          SplashSuccessState(),
        );
      },
    );
  }
}
