import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:simple_flutter/core/constant/static_constant.dart';
import 'package:simple_flutter/core/shared_feature/local_pref/domain/usecase/local_pref_usecase.dart';
import 'package:simple_flutter/get_it.dart';

Dio addInterceptors({required final Dio dio}) {
  log('interceptor initialized dio not null');
  return dio
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (
          final RequestOptions options,
          final RequestInterceptorHandler handler,
        ) async =>
            requestInterceptor(options, handler),
        onError:
            (final DioError dioError, final ErrorInterceptorHandler handler) =>
                errorInterceptor(dioError, handler),
      ),
    );
}

dynamic requestInterceptor(
  final RequestOptions options,
  final RequestInterceptorHandler handler,
) async {
  {
    final LocalPrefUsecase prefs = getIt();
    log('requestInterceptor active');
    log('request ${options.uri}');
    if (options.headers.containsKey(StaticConstant.addKey)) {
      log('requires token active');
      options.headers.remove(StaticConstant.addKey);
      final String? token = await prefs.getAuthToken();
      options.headers['Authorization'] = 'Bearer $token';
      return handler.next(options);
    }
    return handler.next(options);
  }
}

dynamic errorInterceptor(
  final DioError dioError,
  final ErrorInterceptorHandler handler,
) async {
  log('Uri : ${dioError.requestOptions.uri}');
  log(' error interceptor message ${dioError.message} stack ${dioError.stackTrace}');
  return handler.next(dioError);
}
