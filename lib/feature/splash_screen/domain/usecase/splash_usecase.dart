import 'dart:developer';

class SplashUsecase {
  Future<bool> initApp() async {
    log('start usecase init');
    await Future.delayed(const Duration(seconds: 5));
    log('finish init');
    return true;
  }
}
