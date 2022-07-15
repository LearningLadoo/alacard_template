import 'dart:async';
import 'dart:io';
import 'dart:ui' as UI;
import 'dart:typed_data';
import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/database/databaseHelper.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/providers/templateData.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/template/editTemplate.dart';
import 'package:alacard_template/utils/template/templateFieldsLayer.dart';
import 'package:alacard_template/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
// this is specifically for templates and by default it is for front
class TemplateCardFace extends StatefulWidget {
  CardData cardData;
  CRUD crud;
  TemplateCardFace(this.cardData,{this.crud=CRUD.update});
  @override
  _TemplateCardFaceState createState() => _TemplateCardFaceState();
}

class _TemplateCardFaceState extends State<TemplateCardFace> {
late double _ratio,height;
double? width;
late CardData _cardData ;
late bool _isBusiness;
late ThemeData themeData;
late String _path;

final _tempKey = GlobalKey<ScaffoldState>();

@override
  void initState() {
    _cardData = widget.cardData;
    _isBusiness = isBusinessCard(_cardData);
    frontKey = _tempKey;
    try {
      print("gttt init $_path");
    } catch (e) {
      print(e);
    }
    super.initState();
  }

@override
Widget build(BuildContext context) {
  try {
    print("gttt build $_path $width");
  } catch (e) {
    logger.e(e);
  }
    themeData = Theme.of(context);
    return OnWidgetLoader(
        themeData: themeData,
        child: Builder(builder: (context) {
          return FutureBuilder(
              future: loadUiImage(),
              builder: (BuildContext context, AsyncSnapshot<UI.Image?> img) {
                if(img.hasData&&img.data!=null)p_templateImage = img.data; // initializing so that it can be used later when save is pressed
                double? ratio = (p_templateImage!=null)? p_templateImage!.height/p_templateImage!.width : 0.5;
                if (img.hasData||width!=null) {
                  _ratio = ratio;
                  width = deviceWidth - medium;
                  height = _ratio * width!;
                  logger.i("dimensions ${p_templateImage!.height} ${p_templateImage!.width} $_ratio");
                  return AbsorbPointer(
                    absorbing: widget.crud == CRUD.read,
                    child: Center(
                      child: shadowWidget(
                        SizedBox(
                          height: height,
                          width: width,
                          child: Stack(
                            children: [
                              finalGraphics(themeData),
                              // editing buttons on right
                              editableCardWidget(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  print("unable to get ratio - $ratio");
                  return Container(height: 100,width: 100,);
                }
              });
        }));
  }

Widget shadowWidget(Widget? child) {
  double offset = 8;
  Color color = (Theme.of(context).shadowColor);
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
    width: width,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      gradient: LinearGradient(
        begin: Alignment.lerp(Alignment.centerLeft, Alignment.topLeft, 0.5)!,
        end: Alignment.lerp(Alignment.centerRight, Alignment.bottomRight, 0.5)!,
        colors: [color, color],
      ),
      boxShadow: shadowList,
    ),
    child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: child ?? Center()),
  );
}
Widget editableCardWidget(){
  return Container(
      width : width,
      // height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // edit template
          if(!_isBusiness)
            Padding(
              padding: EdgeInsets.only(top:8),
              child: EmbossBg(
                large-small,
                large-small,
                themeData: themeData,
                depth: 5,
                child: ButtonType2(
                    themeData: themeData,
                    onPressed: () {
                      openBottomSheet(context, EditTemplate());
                    },
                    height: large-small,
                    width: large -small,
                    icon: Icons.edit_rounded),
              ),
            ),
        ],
      )
  );
}
Widget finalGraphics(ThemeData themeData){
  // double height=(size!=null?size!:1.0)*(width);
  return RepaintBoundary(
    key: _tempKey,
    child: SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: [
          // background image
          getPictureWidget(),
          // fields
          TemplateFieldsLayer(_cardData,isBusiness: _isBusiness,height: height,width: width!,)
        ],
      ),
    ),
  );
}
Widget getPictureWidget(){
  try {
      logger.i("template type = ${_cardData.templateName!["templateType"]}");
      // display editable screen
      switch(_cardData.templateName!["templateType"]){
        case "svg" :
        // get String of svg file
          String svgString = File(_path).readAsStringSync();
          svgString = svgString.replaceAll("color1", "#000000");
          logger.i(svgString);
          return SizedBox(
              height: height,
              width: width,
              child: SvgPicture.string(svgString,height: height,)
          );
        case "jpg":
          logger.i("imagePath : "+_path);
          return Image.memory(
            Uint8List.fromList(File(_path).readAsBytesSync()),);
        default: return(Center());
      }
  }
  catch(e){
    logger.e(e);
    return(Center());
  }
}
Future<UI.Image?> loadUiImage() async {
  _path = getTemplateLocalPath(tempSubPath: getTemplateSubPath(cardData: Provider.of<Variables>(context,listen: false).tempCardDetails , forLocal: true , code : p_imageAsTemplateCode??_cardData.templateName!["tempCode"])! , fileName:CardFace.front.name,key: "jpg" );
  final Completer<UI.Image?> completer = Completer();
  try {
    File imageFile = File(_path);
    UI.Image image = await decodeImageFromList(imageFile.readAsBytesSync());
    completer.complete(image);
    print("gttt - $_path");
    return completer.future;
  } catch (e) {
    logger.e(e);
    print("gttt e - $_path");
    completer.complete(null) ;
    return completer.future;
  }
}
}
