import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/screens/manageCardDetails/utils/imageUploadDialog.dart';
import 'package:alacard_template/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

final String _TAG = "Card Face Widget";

class CardFaceWidget extends StatefulWidget {
  CardFace? cardFace;
  CardData? cardData;
  bool isMine , isBusiness; // if its a template then only it will be not null
  double? size ;
  CRUD crud;

  @override
  _CardFaceWidgetState createState() => _CardFaceWidgetState();

  CardFaceWidget(
      {this.cardFace,
      this.cardData,
      this.size,
      this.isBusiness = false,
      this.isMine = false,
      this.crud = CRUD.read});
}

class _CardFaceWidgetState extends State<CardFaceWidget> {
  Map<String,dynamic>? positions;
  CardFace? cardFace;
  CardData? cardData;
  bool? isUpdated = false;
  String? path;
  double? size ,tx,ty ; // size is the ratio of height / width
  late double width , height;
  bool  isEditable = false , isArrows = false , isMine = false;
  double imgHeight = deviceWidth*0.6;
  //(deviceWidth - medium)/2,
  bool getLatestCard = false;
  @override
  void initState() {
    cardFace = widget.cardFace;
    cardData = widget.cardData;
    isMine = widget.isMine;
    // checking the mode in which the card face is accessed
    if(widget.crud != CRUD.read && (cardData==null)) cardData=CardData();
    size = widget.size;
    path = getImagePath(cardFace: cardFace , crud : widget.crud ,isMine: isMine, cardData: cardData);
    logger.i("$_TAG : init path - $path , Card Face is ${cardFaceToString(cardFace)}  ${cardData!.getMapFromCardData()}");
    super.initState();
  }

//pick image->crop it->compress it -> save as cardTempFront/Back
// Now when submit->check who are edited->save them with id
//          back-> delete those temp images!

  @override
  Widget build(BuildContext buildContext) {
    ThemeData themeData = Theme.of(buildContext);
    path = getImagePath(cardFace: cardFace , isMine: isMine, crud : widget.crud, cardData: cardData);
    logger.i("ayeee + $path");
    print("$_TAG : path - $path , Card Face is ${cardFaceToString(cardFace)} $isUpdated");

    return OnWidgetLoader(
        themeData: themeData,
        child: Builder(builder: (context) {
          return FutureBuilder(
              future: _calculateImageRatio(path),
              builder: (BuildContext context, AsyncSnapshot<double> ratio){
                if((ratio.hasData) && path!=null) {
                  print("gtt - ${ratio.data}");
                  size = ratio.data == 0.0 ? 0.5 : ratio.data;
                  width = (cardFace != CardFace.icon)
                      ? (deviceWidth - medium)
                      : large;
                  height = (size != null ? size! : 1.0) * (width);
                  logger.i("bro $height $width $size");
                  return AbsorbPointer(
                    absorbing: widget.crud == CRUD.read,
                    child: Container(
                      height: height,
                      width: width,
                      child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            isArrows = false;
                          });
                          print("tapped");
                            AlacardDialog(
                              context,
                              child: ImageUploadDialog(context, cardFace: cardFace ,cardData: cardData,isMine: isMine,),
                            );
                        },
                        child: path == NO_IMAGE_FOUND
                            ? defaultTile(themeData)
                            : getPictureWidget(cardData!, path! , themeData),
                      ),
                    ),
                  );
                }else {
                  print("gtt nopme - ${ratio.data}");
                  return Center();
                }
              }
          );
        }));
  }
  Widget getPictureWidget(CardData cardData, String path , ThemeData themeData){
    try {
        // display only images
        return Image.memory(
          Uint8List.fromList(File(path).readAsBytesSync(),),
          width: width,
          height: height,
        );
    }
    catch(e){
      logger.e(e);
      path = NO_IMAGE_FOUND;
      return defaultTile(themeData);
    }

  }
  Widget defaultTile(ThemeData themeData){
    width = deviceWidth - medium;
    height = width/2;
    return Container(
      height: height,
      width: width,
      color: themeData.scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(widget.crud != CRUD.read)
            Icon(
            Icons.add_rounded,
            size:cardFace!=CardFace.icon?large:medium*1.2,
          ),
          SizedBox(
            height: cardFace!=CardFace.icon?medium:0.0,
            child: FittedBox(
              child: Text(
                  "${widget.crud != CRUD.read?"Add":"No"} ${cardFaceToString(cardFace)} ${cardFace!=CardFace.icon?"Image":""}",
                  // style: themeData.textTheme.subtitle1
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<double> _calculateImageRatio(String? path) async{
    Completer<double> completer = Completer();
    try {
      if(path==null||path==NO_IMAGE_FOUND||cardFace==CardFace.icon){
            print("gtt pp no - $path $size");
            completer.complete(size??0.0) ;
            return completer.future;
          }
      File imageFile = File(path);
      var image = await decodeImageFromList(imageFile.readAsBytesSync());
      print("gtt pp yes - ${image.width} ${image.height}");
      completer.complete(image.height/image.width);
      print("gtt - $path");
      return completer.future;
    } catch (e) {
      print("gtt pp e - $path $size");
      completer.complete(size??0.0) ;
      return completer.future;
    }
  }
}
