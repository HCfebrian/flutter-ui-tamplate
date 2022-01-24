import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';

abstract class AuthRepoAbs {
  Future<String> registerUser({
    required final String email,
    required final String password,
    required final String username,
  });

  Future<String> loginUser({
    required final String email,
    required final String password,
    final String? username,
  });

  Future loginGoogleOauth();

  Future cancelRequest();

  Future<UserEntity?> getUser();

  Future logout();
}
