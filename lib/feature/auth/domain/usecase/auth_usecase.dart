import 'package:simple_flutter/core/shared_feature/local_pref/domain/usecase/local_pref_usecase.dart';
import 'package:simple_flutter/feature/auth/domain/contract_repo/auth_repo_abs.dart';

class AuthUsecase {
  final AuthRepoAbs authRepo;
  final LocalPrefUsecase localPrefUsecase;

  AuthUsecase({
    required this.authRepo,
    required this.localPrefUsecase,
  });

  Future registerUser({
    required final String email,
    required final String password,
    final String? username,
  }) async {
    final String token =
        await authRepo.registerUser(email: email, password: password);

    return localPrefUsecase.saveAuthToken(token: token);
  }

  Future loginUser({
    required final String email,
    required final String password,
  }) async {
    final token = await authRepo.loginUser(email: email, password: password);
    return localPrefUsecase.saveAuthToken(token: token);
  }

  Future loginWithGoogle() async{
    authRepo.loginGoogleOauth();
    return;
  }

  Future logout(){
    return localPrefUsecase.deleteAuthToken();
  }

  Future cancelRequest() {
    return authRepo.cancelRequest();
  }

}
