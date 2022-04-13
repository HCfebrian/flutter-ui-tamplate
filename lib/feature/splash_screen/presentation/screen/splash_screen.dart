import 'dart:developer';
import 'dart:math' as math;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_flutter/feature/splash_screen/presentation/bloc/splashscreen_bloc.dart';
import 'package:simple_flutter/utils/route_generator.dart';
import 'package:simple_flutter/feature/auth/presentation/bloc/user/user_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false;

  @override
  void initState() {
    BlocProvider.of<SplashScreenBloc>(context).add(SplashScreenInitEvent());
    BlocProvider.of<UserBloc>(context).add(UserStateStreamInitEvent());
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SplashScreenBloc, SplashScreenState>(
          listener: (context, state) {
            if (state is SplashSuccessState) {
              if (isLoggedIn) {
                Navigator.pushNamed(context, AppRoute.messagesList);
              } else {
                Navigator.pushReplacementNamed(context, AppRoute.login);
              }
            }
          },
        ),
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserLoggedInState) {
              isLoggedIn = true;
            } else {
              isLoggedIn = false;
            }
          },
        ),
      ],
      child: Scaffold(
        body: Center(
          child: Image.asset('assets/image/logo.png'),
        ),
      ),
    );
  }
}

int createUniqueID(int maxValue) {
  math.Random random = math.Random();
  return random.nextInt(maxValue);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  log('Handling a background message: ${message.messageId}');

  if (!AwesomeStringUtils.isNullOrEmpty("${message.data["SENDER_NAME"]}",
          considerWhiteSpaceAsEmpty: true) ||
      !AwesomeStringUtils.isNullOrEmpty("${message.data["BODY"]}",
          considerWhiteSpaceAsEmpty: true)) {
    log(" title : ${message.data["SENDER_NAME"]}");
    log(" body : ${message.data["BODY"]}");
    log(" data : ${message.data}");
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: createUniqueID(AwesomeNotifications.maxID),
            groupKey: "chat_group",
            channelKey: 'chat_channel',
            summary: "chatName",
            title: "${message.data["SENDER_NAME"]}",
            body: "${message.data["BODY"]}",
            largeIcon: "${message.data["USER_PROFILE_URL"]}",
            notificationLayout: NotificationLayout.Messaging,
            category: NotificationCategory.Message),
        actionButtons: [
          // NotificationActionButton(
          //   key: 'REPLY',
          //  FirebaseMessaging.onBackgroundMessage label: 'Reply',
          //   buttonType: ActionButtonType.InputField,
          //   autoDismissible: false,
          // ),
          // NotificationActionButton(
          //   key: 'READ',
          //   label: 'Mark as Read',
          //   autoDismissible: true,
          //   buttonType: ActionButtonType.InputField,
          // )
        ]);
  } else {
    log(" title : ${message.data["SENDER_NAME"]}");
    log(" body : ${message.data["BODY"]}");
    log(" data : ${message.data}");
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: createUniqueID(AwesomeNotifications.maxID),
            groupKey: "chat_group",
            channelKey: 'chat_channel',
            summary: "chatName",
            title: "${message.data["SENDER_NAME"]}",
            body: "${message.data["BODY"]}",
            largeIcon: "${message.data["USER_PROFILE_URL"]}",
            notificationLayout: NotificationLayout.Messaging,
            category: NotificationCategory.Message),
        actionButtons: [
          // NotificationActionButton(
          //   key: 'REPLY',
          //  FirebaseMessaging.onBackgroundMessage label: 'Reply',
          //   buttonType: ActionButtonType.InputField,
          //   autoDismissible: false,
          // ),
          // NotificationActionButton(
          //   key: 'READ',
          //   label: 'Mark as Read',
          //   autoDismissible: true,
          //   buttonType: ActionButtonType.InputField,
          // )
        ]);
  }
}
