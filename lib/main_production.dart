import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_flutter/core/constant/static_constant.dart';
import 'package:simple_flutter/core/utils/flavour_config.dart';
import 'package:simple_flutter/main.dart';

void main() {
  FlavorConfig(
    flavor: Flavor.production,
    color: Colors.deepPurpleAccent,
    values: FlavorValues(baseUrl: StaticConstant.baseUrlProduction),
  );
  runZoned<Future<void>>(
    () async {
      mainInit();
    },
  );
}
