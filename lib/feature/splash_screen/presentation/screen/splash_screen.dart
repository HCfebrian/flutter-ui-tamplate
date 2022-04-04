import 'dart:developer';
import 'dart:math' as math;

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
      await AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: createUniqueID(AwesomeNotifications.maxID),
              groupKey: "chat_group",
              channelKey: 'chat_channel',
              summary: "chatName",
              title: "${message.notification?.title}",
              body: "${message.notification?.body}",
              notificationLayout: NotificationLayout.Messaging,
              category: NotificationCategory.Message),
          actionButtons: [
            NotificationActionButton(
              key: 'REPLY',
              label: 'Reply',
              buttonType: ActionButtonType.InputField,
              autoDismissible: false,
            ),
            NotificationActionButton(
              key: 'READ',
              label: 'Mark as Read',
              autoDismissible: true,
              buttonType: ActionButtonType.InputField,
            )
          ]);

      // AwesomeNotifications().createNotification(
      //   content: NotificationContent(
      //     id: DateTime.now().microsecond,
      //     channelKey: 'chat_channel',
      //     groupKey: "chat_group",
      //     displayOnBackground: true,
      //     displayOnForeground: false,
      //     notificationLayout: NotificationLayout.Messaging,
      //     title: "${message.notification?.title}",
      //     body: "${message.notification?.body}",
      //   ),
      // );
      log('Message also contained a notification: ${message.notification!.title.toString()}');
    }
  }

  @override
  void initState() {
    BlocProvider.of<SplashScreenBloc>(context).add(SplashScreenInitEvent());
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((message) async {
      if (message.notification != null) {
        log(" title : ${message.notification?.title}");
        log(" body : ${message.notification?.body}");
        log(" data : ${message.data}");
        await AwesomeNotifications().createNotification(
            content: NotificationContent(
                id: createUniqueID(AwesomeNotifications.maxID),
                groupKey: "chat_group",
                channelKey: 'chat_channel',
                summary: "chatName",
                title: "${message.notification?.title}",
                body: "${message.notification?.body}",
                largeIcon: "${message.data["USER_PROFILE_URL"]}",
                notificationLayout: NotificationLayout.Messaging,
                category: NotificationCategory.Message),
            actionButtons: [
              // NotificationActionButton(
              //   key: 'REPLY',
              //   label: 'Reply',
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

        // AwesomeNotifications().createNotification(
        //   content: NotificationContent(
        //     id: DateTime.now().microsecond,
        //     channelKey: 'chat_channel',
        //     groupKey: "chat_group",
        //     displayOnBackground: true,
        //     displayOnForeground: false,
        //     notificationLayout: NotificationLayout.Messaging,
        //     title: "${message.notification?.title}",
        //     body: "${message.notification?.body}",
        //   ),
        // );
        log('Message also contained a notification: ${message.notification!.title.toString()}');
      }
    });
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

int createUniqueID(int maxValue) {
  math.Random random = math.Random();
  return random.nextInt(maxValue);
}
