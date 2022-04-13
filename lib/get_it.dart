import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_flutter/core/color/chat_thame.dart';
import 'package:simple_flutter/core/shared_feature/chat_util/data/repo/chat_user_repo_impl.dart';
import 'package:simple_flutter/core/shared_feature/chat_util/domain/contract_repo/chat_user_repo_abs.dart';
import 'package:simple_flutter/core/shared_feature/chat_util/domain/usecase/chat_util_usecase.dart';
import 'package:simple_flutter/core/shared_feature/local_pref/data/repo/shared_pref_impl.dart';
import 'package:simple_flutter/core/shared_feature/local_pref/domain/contract_repo/local_pref_abs.dart';
import 'package:simple_flutter/core/shared_feature/local_pref/domain/usecase/local_pref_usecase.dart';
import 'package:simple_flutter/feature/auth/data/repo/auth/auth_firebase_impl.dart';
import 'package:simple_flutter/feature/auth/data/repo/user/user_repo_impl.dart';
import 'package:simple_flutter/feature/auth/domain/contract_repo/auth_repo_abs.dart';
import 'package:simple_flutter/feature/auth/domain/contract_repo/user_repo_abs.dart';
import 'package:simple_flutter/feature/auth/domain/usecase/auth_usecase.dart';
import 'package:simple_flutter/feature/auth/domain/usecase/user_usecase.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/user/user_bloc.dart';
import 'package:simple_flutter/feature/broadcast/broadcast_usecase/broadcast_usecase.dart';
import 'package:simple_flutter/feature/broadcast/presentation/bloc/broadcast_bloc.dart';
import 'package:simple_flutter/feature/chat_detail/data/repo/chat_detail_repo_impl.dart';
import 'package:simple_flutter/feature/chat_detail/domain/contract_repo/chat_detail_repo_abs.dart';
import 'package:simple_flutter/feature/chat_detail/domain/usecase/chat_detail_usecase.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/bloc/chat_detail/chat_detail_bloc.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/bloc/chat_detail_status/chat_detail_status_bloc.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/bloc/chat_loading_indicator/chat_loading_bloc.dart';
import 'package:simple_flutter/feature/chat_list/data/repo/chat_list_repo_impl.dart';
import 'package:simple_flutter/feature/chat_list/domain/contract_repo/chat_repo.dart';
import 'package:simple_flutter/feature/chat_list/domain/usecase/chat_usecase.dart';
import 'package:simple_flutter/feature/chat_list/presentation/bloc/chat_list_bloc.dart';
import 'package:simple_flutter/feature/contact_list/data/repo/contact_list_repo_impl.dart';
import 'package:simple_flutter/feature/contact_list/domain/contract_repo/contact_list_repo_abs.dart';
import 'package:simple_flutter/feature/contact_list/domain/usecase/contact_list_usecase.dart';
import 'package:simple_flutter/feature/splash_screen/domain/usecase/splash_usecase.dart';
import 'package:simple_flutter/feature/splash_screen/presentation/bloc/splashscreen_bloc.dart';

final getIt = GetIt.instance;

void initDepInject() {
// Feature
  //bloc
  getIt.registerFactory(() => ChatLoadingBloc(chatUsecase: getIt()));
  getIt.registerFactory(() => BroadcastBloc(broadcastUsecase: getIt()));
  getIt.registerFactory(() => SplashScreenBloc(splashUsecase: getIt()));
  getIt.registerFactory(() => AuthBloc(authUsecase: getIt()));
  getIt.registerFactory(
    () => ChatDetailBloc(
      chatDetailUsecase: getIt(),
      chatLoadingBloc: getIt(),
    ),
  );
  getIt.registerFactory(() => ChatDetailStatusBloc(chatDetailUsecase: getIt()));
  getIt.registerFactory(() => ChatListBloc(chatUsecase: getIt()));
  getIt.registerFactory(
    () => UserBloc(
      authUsecase: getIt(),
      userUsecase: getIt(),
      chatUtilUsecase: getIt(),
    ),
  );

  //UseCase

  getIt.registerLazySingleton(() => SplashUsecase());
  getIt.registerLazySingleton(() =>
      BroadcastUsecase(chatDetailUsecase: getIt(), chatDetailRepoAbs: getIt()));
  getIt.registerLazySingleton(() => ChatUsecase(chatListRepoAbs: getIt()));
  getIt.registerLazySingleton(() =>
      ChatDetailUsecase(chatDetailRepoAbs: getIt(), userUsecase: getIt()));
  getIt.registerLazySingleton(() => ChatUtilUsecase(chatUserRepoAbs: getIt()));
  getIt.registerLazySingleton(
    () => AuthUsecase(
      authRepo: getIt(),
      localPrefUsecase: getIt(),
      userUsecase: getIt(),
    ),
  );
  getIt.registerLazySingleton(() => LocalPrefUsecase(localPrefAbs: getIt()));
  getIt.registerLazySingleton(
    () => UserUsecase(
      authRepoAbs: getIt(),
      userRepoAbs: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => ContactListUsecase(chatListRepo: getIt()),
  );

  // repo

  getIt.registerLazySingleton<ChatDetailRepoAbs>(
    () => ChatDetailRepoImpl(
        firestore: getIt(), firebaseStorage: getIt(), dio: getIt()),
  );
  getIt.registerLazySingleton<ChatListRepoAbs>(
    () => ChatListRepoImpl(
      firestore: getIt(),
    ),
  );
  getIt.registerLazySingleton<ChatUserRepoAbs>(
    () => ChatUserRepoImpl(firebaseFirestore: getIt()),
  );
  getIt.registerLazySingleton<ContactListRepoAbs>(
    () => ContactListRepoImpl(firebaseFirestore: getIt()),
  );
  getIt.registerLazySingleton<LocalPrefAbs>(
    () => SharedPrefImpl(
      sharedPref: getIt(),
    ),
  );
  getIt.registerLazySingleton<AuthRepoAbs>(
    () => AuthFirebaseImpl(
      firebaseAuth: getIt(),
      firestore: getIt(),
    ),
  );
  getIt.registerLazySingleton<UserRepoAbs>(
    () => UserRepoImpl(
      firebaseAuth: getIt(),
      firestore: getIt(),
      firebaseMessaging: getIt(),
      database: getIt(),
    ),
  );

  //data_source

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
      BaseOptions(),
    ),
  );

  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton(() => FirebaseStorage.instance);
  getIt.registerLazySingleton(() => FirebaseMessaging.instance);
  getIt.registerLazySingleton(() => FirebaseDatabase.instance);
  // getIt.registerLazySingleton(
  //   () => Dio(
  //     BaseOptions(baseUrl: FlavorConfig.instance.values.baseUrl),
  //   ),
  // );
}
