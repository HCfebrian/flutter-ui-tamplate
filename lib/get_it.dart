import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_flutter/core/shared_feature/local_pref/data/repo/shared_pref_impl.dart';
import 'package:simple_flutter/core/shared_feature/local_pref/domain/contract_repo/local_pref_abs.dart';
import 'package:simple_flutter/core/utils/flavour_config.dart';
import 'package:simple_flutter/feature/splash_screen/domain/usecase/splash_usecase.dart';
import 'package:simple_flutter/feature/splash_screen/presentation/bloc/splashscreen_bloc.dart';

final getIt = GetIt.instance;

void initDepInject() {
// Feature
  //bloc
  getIt.registerFactory(() => SplashScreenBloc(splashUsecase: getIt()));

  //UseCase

  getIt.registerLazySingleton(() => SplashUsecase());

  // repo

  getIt.registerLazySingleton<LocalPrefAbs>(
    () => SharedPrefImpl(
      sharedPref: getIt(),
    ),
  );

  //data

  // getIt.registerLazySingleton<BannerRemoteAbs>(
  //     () => BannerRemoteImpl(dio: getIt()));

// Shared
  //feature.history.presentation

  //util

  //network

// External Dependency
  getIt.registerSingletonAsync<SharedPreferences>(
    () async => SharedPreferences.getInstance(),
  );

  getIt.registerLazySingleton(
    () => Dio(
      BaseOptions(baseUrl: FlavorConfig.instance.values.baseUrl),
    ),
  );
}
