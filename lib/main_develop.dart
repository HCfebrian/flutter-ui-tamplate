import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:simple_flutter/core/constant/static_constant.dart';
import 'package:simple_flutter/core/utils/flavour_config.dart';
import 'package:simple_flutter/main.dart';
import 'package:workmanager/workmanager.dart';

const uploadImage = "uploadImage";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    log(" task name " + task);
    log("miaw");
    await Firebase.initializeApp();
    final file = File(inputData!['pathImage'].toString());
    final bytes = file.readAsBytesSync();
    final base64Str = base64Encode(bytes);
    FormData formData = new FormData.fromMap({"source": base64Str});
    Dio dio = Dio();
    final response = await dio.post(
      "https://freeimage.host/api/1/upload?key=6d207e02198a847aa98d0a2a901485a5",
      data: formData,
      onSendProgress: (int sent, int total) {
        log('total ${sent / total}');
        log('total $sent to $total}');
        // AwesomeNotifications().createNotification(
        //   content: NotificationContent(
        //     id: 69,
        //     channelKey: "chat_channel",
        //     title: 'Upload in progress ($sent of $total)',
        //     body: inputData['fileName'].toString(),
        //     notificationLayout: NotificationLayout.ProgressBar,
        //     progress: math.min((sent / total * 100).round(), 100),
        //
        //   ),
        // );
      },
    );
    final uri = response.data["image"]["url"] as String;
    log("urik ${response.data["image"]["url"]}");

    ///
    ///
    ///

    // final user = await userUsecase.getUserData();
    final message = types.PartialImage(
      height: double.parse(inputData['height'].toString()),
      width: double.parse(inputData['width'].toString()),
      size: double.parse(inputData['size'].toString()),
      name: inputData['fileName'].toString(),
      uri: uri,
    );
    //
    final messageMap = message.toJson();
    messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
    messageMap['authorId'] = inputData['userId'].toString();
    messageMap['createdAt'] = FieldValue.serverTimestamp();
    messageMap['updatedAt'] = FieldValue.serverTimestamp();
    messageMap['type'] = 'image';
    messageMap['metadata'] = {};
    log('message map ${messageMap}');

    await FirebaseFirestore.instance
        .collection('$ROOM_COLLECTION/${inputData['room']}/messages')
        .add(messageMap);

    log("ceeeess");
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig(
    flavor: Flavor.develop, //Flavor Type
    color: Colors.deepPurpleAccent, //F// lavor color
    values: FlavorValues(baseUrl: StaticConstant.baseUrlDev),
  ); // Add Flavor base Url

  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
          channelGroupKey: 'chat_channel_group',
          channelKey: 'chat_channel',
          groupKey: 'chat_group',
          channelName: 'chat notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
        )
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupkey: 'chat_channel_group',
            channelGroupName: 'chat group')
      ],
      debug: true);
  runZoned<Future<void>>(() async {
    mainInit();
  });
}
