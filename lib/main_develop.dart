import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_flutter/core/constant/static_constant.dart';
import 'package:simple_flutter/core/utils/flavour_config.dart';
import 'package:simple_flutter/main.dart';
import 'package:simple_flutter/main.dart';

void main() {
  FlavorConfig(
    flavor: Flavor.develop, //Flavor Type
    color: Colors.deepPurpleAccent, //F// lavor color
    values: FlavorValues(baseUrl: StaticConstant.baseUrlDev),
  ); // Add Flavor base Url
  runZoned<Future<void>>(() async {
    mainInit();
  });
}
