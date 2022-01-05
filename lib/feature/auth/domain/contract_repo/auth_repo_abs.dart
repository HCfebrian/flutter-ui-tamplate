abstract class AuthRepoAbs {
  Future<String> registerUser({
    required final String email,
    required final String password,
    final String? username,
  });

  Future<String> loginUser({
    required final String email,
    required final String password,
    final String? username,
  });

  Future cancelRequest();

}
