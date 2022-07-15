import 'package:alacard_template/constants.dart';
import 'package:alacard_template/utils/common/imageShadow.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FullScreenLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      color: themeData.scaffoldBackgroundColor,
      height: deviceHeight,
      width: deviceWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ImageShadow(
            assetPath: "$iconsDir/whiteLogo.png",
            color: themeData.colorScheme.onPrimary,
            shadowColor: themeData.colorScheme.primary,
            height: deviceHeight*0.4,
            width: deviceWidth,
          ),
          SizedBox(
              height: medium,
              child: Lottie.asset("$lottieDir/loader.json"))
        ],
      ),
    );
  }
}
