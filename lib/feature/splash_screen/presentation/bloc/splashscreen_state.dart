part of 'splashscreen_bloc.dart';

abstract class SplashScreenState extends Equatable {
  const SplashScreenState();

  @override
  List<Object?> get props => [];
}

class SplashInitState extends SplashScreenState {}

class SplashLoadingState extends SplashScreenState {}

class SplashErrorState extends SplashScreenState {}

class SplashSuccessState extends SplashScreenState {}
