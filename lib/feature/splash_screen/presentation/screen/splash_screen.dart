import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_flutter/feature/splash_screen/presentation/bloc/splashscreen_bloc.dart';
import 'package:simple_flutter/utils/route_generator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    log("message background ${message.data} ");

    if (message.notification != null) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().microsecond,
          channelKey: 'chat_channel',
          groupKey: "chat_group",
          displayOnBackground: true,
          displayOnForeground: false,
          title: "${message.notification?.title}",
          body: "${message.notification?.body}",
        ),
      );
      log('Message also contained a notification: ${message.notification!.title.toString()}');
    }
  }

  @override
  void initState() {
    BlocProvider.of<SplashScreenBloc>(context).add(SplashScreenInitEvent());
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashScreenBloc, SplashScreenState>(
      listener: (context, state) {
        if (state is SplashSuccessState) {
          Navigator.pushReplacementNamed(context, AppRoute.login);
        }
      },
      child: Scaffold(
        body: Center(
          child: Image.asset('assets/image/logo.png'),
        ),
      ),
    );
  }
}
