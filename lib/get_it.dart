import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_flutter/core/shared_feature/chat_util/data/repo/chat_user_repo_impl.dart';
import 'package:simple_flutter/core/shared_feature/chat_util/domain/contract_repo/chat_user_repo_abs.dart';
import 'package:simple_flutter/core/shared_feature/chat_util/domain/usecase/chat_util_usecase.dart';
import 'package:simple_flutter/core/shared_feature/local_pref/data/repo/shared_pref_impl.dart';
import 'package:simple_flutter/core/shared_feature/local_pref/domain/contract_repo/local_pref_abs.dart';
import 'package:simple_flutter/core/shared_feature/local_pref/domain/usecase/local_pref_usecase.dart';
import 'package:simple_flutter/core/utils/flavour_config.dart';
import 'package:simple_flutter/feature/auth/data/repo/auth/auth_firebase_impl.dart';
import 'package:simple_flutter/feature/auth/data/repo/user/user_repo_impl.dart';
import 'package:simple_flutter/feature/auth/domain/contract_repo/auth_repo_abs.dart';
import 'package:simple_flutter/feature/auth/domain/contract_repo/user_repo_abs.dart';
import 'package:simple_flutter/feature/auth/domain/usecase/auth_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_flutter/feature/auth/domain/usecase/user_usecase.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/user/user_bloc.dart';
import 'package:simple_flutter/feature/splash_screen/domain/usecase/splash_usecase.dart';
import 'package:simple_flutter/feature/splash_screen/presentation/bloc/splashscreen_bloc.dart';

final getIt = GetIt.instance;

void initDepInject() {
// Feature
  //bloc
  getIt.registerFactory(() => SplashScreenBloc(splashUsecase: getIt()));
  getIt.registerFactory(() => AuthBloc(authUsecase: getIt()));
  getIt.registerFactory(
    () => UserBloc(
      authUsecase: getIt(),
      userUsecase: getIt(),
      chatUtilUsecase: getIt(),
    ),
  );

  //UseCase

  getIt.registerLazySingleton(() => SplashUsecase());
  getIt.registerLazySingleton(() => ChatUtilUsecase(chatUserRepoAbs: getIt()));
  getIt.registerLazySingleton(
      () => AuthUsecase(authRepo: getIt(), localPrefUsecase: getIt()));
  getIt.registerLazySingleton(() => LocalPrefUsecase(localPrefAbs: getIt()));
  getIt.registerLazySingleton(
    () => UserUsecase(
      authRepoAbs: getIt(),
      userRepoAbs: getIt(),
    ),
  );

  // repo

  getIt.registerLazySingleton<ChatUserRepoAbs>(
    () => ChatUserRepoImpl(firebaseFirestore: getIt()),
  );
  getIt.registerLazySingleton<LocalPrefAbs>(
    () => SharedPrefImpl(
      sharedPref: getIt(),
    ),
  );
  getIt.registerLazySingleton<AuthRepoAbs>(
    () => AuthFirebaseImpl(firebaseAuth: getIt()),
  );
  getIt.registerLazySingleton<UserRepoAbs>(
    () => UserRepoImpl(firebaseAuth: getIt()),
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

  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  // getIt.registerLazySingleton(
  //       () => Dio(
  //     BaseOptions(baseUrl: FlavorConfig.instance.values.baseUrl),
  //   ),
  // );
}
