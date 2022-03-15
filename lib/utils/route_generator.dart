import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_flutter/core/shared_feature/not_found/screen/not_found_screen.dart';
import 'package:simple_flutter/feature/auth/presentation/screen/login_screen.dart';
import 'package:simple_flutter/feature/auth/presentation/screen/register_screen.dart';
import 'package:simple_flutter/feature/auth/presentation/screen/welcome_screen.dart';
import 'package:simple_flutter/feature/chat_detail/presentation/screen/chat_detail_screen.dart';
import 'package:simple_flutter/feature/chat_list/presentation/messages_screen.dart';
import 'package:simple_flutter/feature/splash_screen/presentation/screen/splash_screen.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // final args = settings.arguments;

    switch (settings.name) {
      case AppRoute.init:
        return routeTransition(const SplashScreen());

      case AppRoute.messagesList:
        return routeTransition(const MessagesList());

      case AppRoute.login:
        return routeTransition(const LoginPage());

      case AppRoute.register:
        return routeTransition(const SignUpPage());

      case AppRoute.welcome:
        return routeTransition(const WelcomePage());

      case AppRoute.detailChat:
        return routeTransition(
          ChatDetail(
            name: ((settings.arguments! as Map)['name']).toString(),
            room: (settings.arguments! as Map)['room'] as types.Room,
            myUserId: ((settings.arguments! as Map)['myUserId']).toString(),
            myUsername: ((settings.arguments! as Map)['myUsername']).toString(),
          ),
        );
      default:
        return routeTransition(const NotFoundScreen());
    }
  }
}

class AppRoute {
  static const String init = '/';
  static const String messagesList = '/messages';
  static const String login = '/login';
  static const String register = '/signUp';
  static const String detailChat = '/detailChat';
  static const String welcome = '/welcome';
  static const String notFound = '/notFound';
}

Route<dynamic> routeTransition(Widget widget) {
  return FadeTransitionRouteBuilder(widget);
}

class FadeTransitionRouteBuilder extends PageRouteBuilder {
  FadeTransitionRouteBuilder(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return page;
          },
          transitionDuration: duration,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return Align(
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}
