import 'package:simple_flutter/core/constant/static_constant.dart';
import 'package:simple_flutter/core/shared_feature/local_pref/domain/contract_repo/local_pref_abs.dart';

class LocalPrefUsecase {
  final LocalPrefAbs localPrefAbs;

  LocalPrefUsecase({required this.localPrefAbs});

  Future saveAuthToken({required String token}) async {
    return localPrefAbs.setString(
      key: StaticConstant.keyAuthToken,
      value: token,
    );
  }

  Future<String?> getAuthToken() async {
    return localPrefAbs.getString(key: StaticConstant.keyAuthToken);
  }

  Future deleteAuthToken() {
    return localPrefAbs.setString(
      key: StaticConstant.keyAuthToken,
      value: '',
    );
  }
}
