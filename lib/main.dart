import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_flutter/core/constant/static_constant.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/user/user_bloc.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/bloc/chat_detail/chat_detail_bloc.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/bloc/chat_detail_status/chat_detail_status_bloc.dart';
import 'package:simple_flutter/feature/chat_list/presentation/bloc/chat_list_bloc.dart';
import 'package:simple_flutter/feature/splash_screen/presentation/bloc/splashscreen_bloc.dart';
import 'package:simple_flutter/get_it.dart';
import 'package:simple_flutter/translations/codegen_loader.g.dart';
import 'package:simple_flutter/utils/route_generator.dart';

Future<void> mainInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  initDepInject();
  await Firebase.initializeApp();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      assetLoader: const CodegenLoader(),
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SplashScreenBloc>(
          create: (context) => getIt(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => getIt(),
        ),
        BlocProvider<UserBloc>(
          create: (context) => getIt(),
        ),
        BlocProvider<ChatDetailBloc>(
          create: (context) => getIt(),
        ),
        BlocProvider<ChatListBloc>(
          create: (context) => getIt(),
        ),
        BlocProvider<ChatDetailStatusBloc>(
          create: (context) => getIt(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: () => MaterialApp(
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          locale: context.locale,
          onGenerateRoute: RouteGenerator.generateRoute,
          title: StaticConstant.baseUrlDev,
          initialRoute: AppRoute.init,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
        ),
      ),
    );
  }
}
