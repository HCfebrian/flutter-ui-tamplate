import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:simple_flutter/core/color/chat_thame.dart';
import 'package:simple_flutter/utils/route_generator.dart';

class ColorConfiguratorScreen extends StatefulWidget {
  const ColorConfiguratorScreen({Key? key}) : super(key: key);

  @override
  State<ColorConfiguratorScreen> createState() =>
      _ColorConfiguratorScreenState();
}

class _ColorConfiguratorScreenState extends State<ColorConfiguratorScreen> {
  Color appBarColor = ChatThemeCustom.barColor;
  Color appBarContentColor = ChatThemeCustom.barContentColor;

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoute.messagesList,
          (route) => false,
        );
      },
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: Icon(Icons.arrow_back, color: ChatThemeCustom.barContentColor),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    appBarColor = ChatThemeCustom.getBarColor();
    appBarContentColor = ChatThemeCustom.getBarContentColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: _backButton(),
        backgroundColor: appBarColor,
        title: Text(
          'Color Picker',
          style: TextStyle(color: appBarContentColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('App Bar Color'),
                ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Pick a color!'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: const Color(0xff443a49),
                              onColorChanged: (color) {
                                log(color.toString());
                                ChatThemeCustom().setBarColor(color: color);
                                appBarColor = color;
                              },
                            ),
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              child: const Text('Got it'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                    setState(() {});
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('App Bar Content Color'),
                ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Pick a color!'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: const Color(0xff443a49),
                              onColorChanged: (color) {
                                log(color.toString());
                                ChatThemeCustom().setBarContentColor(color: color);
                                appBarContentColor = color;
                              },
                            ),
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              child: const Text('Got it'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                    setState(() {});
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('App Bar Content Color'),
                ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Pick a color!'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: const Color(0xff443a49),
                              onColorChanged: (color) {
                                log(color.toString());
                                ChatThemeCustom().setBarContentColor(color: color);
                                appBarContentColor = color;
                              },
                            ),
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              child: const Text('Got it'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                    setState(() {});
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
