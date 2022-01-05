part of 'splashscreen_bloc.dart';

abstract class SplashscreenEvent extends Equatable {
  const SplashscreenEvent();
}

class SplashScreenInitEvent extends SplashscreenEvent {
  @override
  List<Object?> get props => [];
}
