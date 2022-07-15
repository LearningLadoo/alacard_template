import 'dart:convert';
import 'dart:io';

import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/utils/common/cardFaceWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//todo use the exif data to get height and width of image
String _Tag = "My-Card-Slider";

class MyCardSlider extends StatefulWidget {
  CardData? cardData;
  CRUD crud;
  MyCardSlider({this.cardData,this.crud=CRUD.read});
  @override
  _MyCardSliderState createState() => _MyCardSliderState();
}

class _MyCardSliderState extends State<MyCardSlider> {
  CardFace activeCardFace = CardFace.front; // tells the active card face
  late ThemeData themeData;
  Map<String, dynamic>? _allPositions;
  CardData? _cardData;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _cardData = widget.cardData;
    logger.i(" ${_cardData!.templateName} ${_cardData!.templateName!["back"].isEmpty} and crud is ${widget.crud}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        print("$_Tag :${details.velocity.pixelsPerSecond.dx} active card is $activeCardFace ");
        if (details.velocity.pixelsPerSecond.dx < -300 &&
            activeCardFace == CardFace.front) {
          setState(() {
            activeCardFace = CardFace.back;
          });
        } else if (details.velocity.pixelsPerSecond.dx > 300 &&
            activeCardFace == CardFace.back) {
          setState(() {
            activeCardFace = CardFace.front;
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              SizedBox(
                height: (deviceWidth - medium)/2,
              ),
              Visibility(
                  visible: (activeCardFace == CardFace.front)
                      ? true
                      : false,
                  child: shadowWidget(CardFaceWidget(
                    crud: widget.crud,
                    cardFace: CardFace.front,
                    cardData: _cardData,
                    isMine: true,))),
              Visibility(
                  visible: (activeCardFace == CardFace.back)
                      ? true
                      : false,
                  child: shadowWidget(CardFaceWidget(
                    crud: widget.crud,
                    cardFace: CardFace.back,
                    cardData: _cardData,
                    isMine: true,)))
            ],
          ),
          Spacing().mediumWidget,
          //indicator
         Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              indicator(CardFace.front),
              SizedBox(width: small),
              indicator(CardFace.back),
            ],
          )
        ],
      ),
    );
  }

  Widget indicator(CardFace cardFace) {
    Color color;
    color = themeData.scaffoldBackgroundColor;
    color = getAdjustColor(color, (activeCardFace == cardFace) ? -25 : -10);

    return Container(
      height: small,
      width: large,
      decoration: BoxDecoration(
        color:color.withOpacity(0.7),
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }

  Widget shadowWidget(Widget? child) {
    double offset = 8;
    Color color = (themeData.shadowColor);
    Color darkColor = getAdjustColor(color, -offset * (themeMode == ThemeMode.light ? 2 : 1));
    Color lightColor = color;
    List<BoxShadow> shadowList = [
      BoxShadow(
        color: darkColor,
        offset: Offset(offset, offset),
        blurRadius: offset,
      ),
      BoxShadow(
        color: lightColor.withOpacity(0.8),
        offset: Offset(
          -offset,
          -offset,
        ),
        blurRadius: offset,
      ),
    ];
    return Container(
      width: deviceWidth - medium,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        gradient: LinearGradient(
          begin: Alignment.lerp(Alignment.centerLeft, Alignment.topLeft, 0.5)!,
          end: Alignment.lerp(
              Alignment.centerRight, Alignment.bottomRight, 0.5)!,
          colors: [color, color],
        ),
        boxShadow: shadowList,
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: child ?? Center()),
    );
  }

}
// todo check the template over here and call the get all positions here with the provider
// the images will be saved in template part of the local device and then we can proceed as normal