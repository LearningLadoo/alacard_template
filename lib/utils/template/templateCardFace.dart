import 'dart:async';
import 'dart:developer';
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
bool isGridOn = true;
final _tempKey = GlobalKey<ScaffoldState>();
Widget? pictureWidget; // saves p_templateImage in the form of Image instead of UI.image
String? svgString; // the string of svg image so that we can replace colors to required colors
Map<String,dynamic>? oldColors; // old colors is used to compare the colors with tempCardData, if there is change then it is updated to current colors

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
  reBuildTheBg();
    themeData = Theme.of(context);
    return OnWidgetLoader(
        themeData: themeData,
        child: Builder(builder: (context) {
          return FutureBuilder(
              future: loadUiImage(),
              builder: (BuildContext context, AsyncSnapshot<UI.Image?> img) {
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
                              // grid
                              if(isGridOn)Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(width: 1,color: Colors.grey.shade700.withOpacity(0.0),),
                                  Container(width: 1,color: Colors.grey.shade700.withOpacity(0.5),),
                                  Container(width: 1,color: Colors.grey.shade700.withOpacity(0.5),),
                                  Container(width: 1,color: Colors.grey.shade700.withOpacity(0.5),),
                                  Container(width: 1,color: Colors.grey.shade700.withOpacity(0.5),),
                                  Container(width: 1,color: Colors.grey.shade700.withOpacity(0.0),),
                                ],
                              ),
                              if(isGridOn)Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(height: 1,color: Colors.grey.shade700.withOpacity(0.0),),
                                  Container(height: 1,color: Colors.grey.shade700.withOpacity(0.5),),
                                  Container(height: 1,color: Colors.grey.shade700.withOpacity(0.5),),
                                  Container(height: 1,color: Colors.grey.shade700.withOpacity(0.5),),
                                  Container(height: 1,color: Colors.grey.shade700.withOpacity(0.5),),
                                  Container(height: 1,color: Colors.grey.shade700.withOpacity(0.0),),
                                ],
                              ),
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
                      setState(() {
                        isGridOn = !isGridOn;
                      });
                    },
                    height: large-small,
                    width: large -small,
                    icon: Icons.grid_4x4_rounded),
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
          SizedBox(
            height: height,
            width: width,
            child: pictureWidget,
          ),
          // fields
          TemplateFieldsLayer(_cardData,isBusiness: _isBusiness,height: height,width: width!,)
        ],
      ),
    ),
  );
}
Future<UI.Image?> getPictureWidget() async{
  try {
      // display editable screen
      switch(_cardData.templateName!["templateType"]){
        case "svg" :
        // get String of svg file, this is the original svg string
          svgString = File(_path).readAsStringSync();
          // editing the colors, the key represents the original colors and if the value is "" then it will remain unchanged but if it is something then it will replace the key color from the svgString
          if(oldColors!=null) {
            for(String i in oldColors!.keys){
              if(!(oldColors![i]==null || oldColors![i]=="") && oldColors![i]!=i) {
                  svgString = svgString!.replaceAll(i, oldColors![i]);
              }
            }
          }
          // getting the height and width pixels from svgString
          List<String> dimensions = svgString!.split("viewBox=\"0 0 ")[1].split("\"")[0].split(" ");
          log("$dimensions \n $svgString");
          // converting svg to UI.Image
          final DrawableRoot svgRoot = await svg.fromSvgString(svgString!,svgString!);
          final UI.Picture picture = svgRoot.toPicture();
          final UI.Image image = await picture.toImage(int.parse(dimensions[0]),int.parse(dimensions[1]));
          return image;
        case "jpg":
          logger.i("imagePath : "+_path);
          return await decodeImageFromList(File(_path).readAsBytesSync());
        default: return null;
      }
  }
  catch(e){
    logger.e(e);
    return null;
  }
}
Future<UI.Image?> loadUiImage() async {
  // updating the oldColors with the latest values
  CardData tempCard = Provider.of<Variables>(context,listen: false).tempCardDetails;
  oldColors = tempCard.templateName!["front"]["colors"];
  log("yhe kk - ${_cardData.templateName!["tempCode"]} $oldColors ${tempCard.getMapFromCardData()}");
  String key = "jpg";
  String? code = p_imageAsTemplateCode??_cardData.templateName!["tempCode"];
  // if the template is inbuilt then assigning the key to create sub-path
  if(code!=null && code.startsWith("in-")){
    key = code.split("-")[1];
    _cardData.templateName!["templateType"] = key;
    _cardData.templateName!["source"] = "personal"; // overwriting the source from inbuilt to personal because another copy will be saved in users Mytemplate folder
  }
  // setting up the path value of the bg image
  _path = getTemplateLocalPath(tempSubPath: getTemplateSubPath(cardData: Provider.of<Variables>(context,listen: false).tempCardDetails , forLocal: true , code : code)!, fileName:CardFace.front.name,key: key );
  final Completer<UI.Image?> completer = Completer();
  try {
    // this try catch handles the failure of assigning p_templateImage for the first time
    try {
      setState(() async{
        p_templateImage = await getPictureWidget();
      });
    } catch (e) {
      p_templateImage = await getPictureWidget();
    }
    // handle null
    if(p_templateImage==null)return null;
    // build the pictureWidget i.e the Image widget which is used to display as bg
    pictureWidget = Image.memory(Uint8List.view((await p_templateImage!.toByteData(format: UI.ImageByteFormat.png))!.buffer));
    UI.Image image = p_templateImage as UI.Image;
    completer.complete(image);
    print("gttt - $_path");
    return completer.future;
  } catch (e) {
    // handling the error and returning null
    print("gttt e - $_path");
    completer.complete(null) ;
    return completer.future;
  }
}
Future<void> reBuildTheBg()async{
  String currColors = Provider.of<TemplateData>(context).myCardTempData!.templateName!["front"]["colors"].toString();
  // check if to rebuilt or not, as the tempcard from provider changes then the condition is checked to whether update the bg image or not
  if(oldColors!=null && oldColors.toString()!=currColors){
    // load the bg image
    print("successfully rebuilt the image");
    await loadUiImage();
  }
}
}
