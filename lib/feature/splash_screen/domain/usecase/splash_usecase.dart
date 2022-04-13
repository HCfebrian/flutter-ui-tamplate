import 'dart:developer';

class SplashUsecase {
  Future<bool> initApp() async {
    await Future.delayed(const Duration(seconds: 1));
    log('finish init');
    return true;
  }
}
