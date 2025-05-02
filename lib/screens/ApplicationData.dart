import 'dart:ui';

import 'package:flutter/material.dart';

class ApplicationData extends StatelessWidget {
  static String name = "";
  static String address = "";
  static String mobile = "";
  static double screenWidth = getScreenWidth();
  static double screenHeight = getScreenHeight();

  static String countryCodeISO = "";
  static bool showVideoPlayer = false;
  static String? imgPath;
  static String? videoPath;
  static String audioMessage = "";
  static Map<String,String> multimediaUrls = {};

  static Map<String,String> thankYouMessages ={};
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  static double getScreenWidth() {
    var pixelRatio = window.devicePixelRatio;

    //Size in physical pixels
    var physicalScreenSize = window.physicalSize;
    var physicalWidth = physicalScreenSize.width;
    var logicalScreenSize = window.physicalSize / pixelRatio;
    var logicalWidth = logicalScreenSize.width;
    var padding = window.padding;

//Safe area paddings in logical pixels
    var paddingLeft = window.padding.left / window.devicePixelRatio;
    var paddingRight = window.padding.right / window.devicePixelRatio;
    var paddingTop = window.padding.top / window.devicePixelRatio;
    var paddingBottom = window.padding.bottom / window.devicePixelRatio;
    return logicalWidth - paddingLeft - paddingRight;
  }

  static double getScreenHeight() {
    var pixelRatio = window.devicePixelRatio;

    //Size in physical pixels
    var physicalScreenSize = window.physicalSize;
    var physicalHeight = physicalScreenSize.height;
    var logicalScreenSize = window.physicalSize / pixelRatio;

    var padding = window.padding;

//Size in logical pixels

    var logicalHeight = logicalScreenSize.height;

//Safe area paddings in logical pixels

    var paddingTop = window.padding.top / window.devicePixelRatio;
    var paddingBottom = window.padding.bottom / window.devicePixelRatio;
    return logicalHeight - paddingTop - paddingBottom;
  }

  static getPopUpToContinue(String title, String content, String child) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [TextButton(onPressed: () {}, child: Text(child))],
    );
  }
}
