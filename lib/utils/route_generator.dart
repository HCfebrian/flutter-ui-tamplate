import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_flutter/core/shared_feature/not_found/screen/not_found_screen.dart';
import 'package:simple_flutter/feature/home/presentation/home_screen.dart';
import 'package:simple_flutter/feature/splash_screen/presentation/screen/splash_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // final args = settings.arguments;

    switch (settings.name) {
      case AppRoute.init:
        return routeTransition(const SplashScreen());
      case AppRoute.home:
        return routeTransition(const HomeScreen());
      default:
        return routeTransition(const NotFoundScreen());
    }
  }
}

class AppRoute {
  static const String init = '/';
  static const String home = '/home';
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
