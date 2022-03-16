import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:simple_flutter/core/constant/static_constant.dart';
import 'package:simple_flutter/core/utils/flavour_config.dart';
import 'package:simple_flutter/main.dart';

void main() {
  FlavorConfig(
    flavor: Flavor.develop, //Flavor Type
    color: Colors.deepPurpleAccent, //F// lavor color
    values: FlavorValues(baseUrl: StaticConstant.baseUrlDev),
  ); // Add Flavor base Url

  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
            channelGroupKey: 'chat_channel_group',
            channelKey: 'chat_channel',
            groupKey: "chat_group",
            channelName: 'chat notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white)
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
