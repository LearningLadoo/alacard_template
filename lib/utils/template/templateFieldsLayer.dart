import 'dart:convert';
import 'dart:io';
import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/providers/templateData.dart';
import 'package:alacard_template/utils/design/editFont.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';
import 'package:provider/provider.dart';
bool isTriggered = false;
class TemplateFieldsLayer extends StatefulWidget {
  double height, width;
  CardData cardData;
  CardFace cardFace;
  bool isBusiness;
  TemplateFieldsLayer(this.cardData,{this.cardFace = CardFace.front, this.isBusiness = false, required this.width, required this.height, });
  @override
  _TemplateFieldsLayerState createState() => _TemplateFieldsLayerState();
}

class _TemplateFieldsLayerState extends State<TemplateFieldsLayer> {
  List<String> displayList = []; // this list handles which fields are in visible on card
  late ThemeData themeData;
  late CardData cardData;
  late CardFace cardFace;
  late bool isBusiness;
  late double height, width;
  @override
  void initState() {
    print("kinemon init");
    cardData = widget.cardData;
    cardFace = widget.cardFace;
    isBusiness = widget.isBusiness;// removing all the elements in display list
    Provider.of<TemplateData>(context,listen: false).updateDisplayList(CRUD.delete, newValues: ["all"],notify: false);
    Map<String,dynamic>? positions = getAllPositions(cardData);
    if(positions!=null) {
      // cardData!.templateName!.addAll(positions!);
      positions = positions[cardFace.name]??{};
      p_templateMap = positions!;
      displayList = positions.keys.toList();// removing all the elements in display list
      // removes colors if present
      displayList.remove("colors");
      Provider.of<TemplateData>(context,listen: false).updateDisplayList(CRUD.update, newValues: displayList,notify: false);
    }
    logger.i("kinemon ${cardFace.name} $positions");
    height= widget.height;
    width = widget.width;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    displayList = Provider.of<TemplateData>(context).displayList!;

    logger.i("kinemon mm $p_templateMap");
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          SizedBox(
            width: width,
            height: height,),
          movableField("title"),
          movableField("name"),
          movableField("businessName"),
          movableField("address"),
          movableField("website"),
          movableField("email"),
          movableField("about"),
          movableField("contactNos"),
          movableField("socialMedias"),
          movableField("customFields"),
        ],
      ),
    );
  }
  Widget movableField(String fieldName){
    if(!(displayList.contains(fieldName)))return Center(); // no further processing if it is not on card
    // height and width of bg image
    logger.i("kinemon alpha $fieldName : ${p_templateMap.keys}");
    if(p_templateMap[fieldName] == null){
      p_templateMap[fieldName] = {};
    }
    // providing position if there isn't any
    if(p_templateMap[fieldName]["position"] == null || p_templateMap[fieldName]["position"] == null ){
      p_templateMap[fieldName].addAll({"position":[0.5,0.5]});
    }
    // providing font style if there isn't any
    // todo add font weight too
    if(p_templateMap[fieldName]["fontStyle"] == null ){
      p_templateMap[fieldName].addAll({"fontStyle": {
        "size": 17,
        "color": [39,44,53,1.0],
        "fontFamily": themeData.textTheme.headline2!.fontFamily!
      },});
    }
    logger.i(p_templateMap[fieldName]);
    // getting text style
    late TextStyle _ts;
    try {
      _ts = PickerFont(fontFamily: p_templateMap[fieldName]["fontStyle"]["fontFamily"]).toTextStyle();
    } catch (e) {
      triggerSnackbarForFontNotFound(fieldName);
      _ts = themeData.textTheme.headline2!;
      logger.e(e);
    }
   TextStyle _style = TextStyle(
        color:  Color.fromRGBO(p_templateMap[fieldName]["fontStyle"]["color"][0], p_templateMap[fieldName]["fontStyle"]["color"][1], p_templateMap[fieldName]["fontStyle"]["color"][2], p_templateMap[fieldName]["fontStyle"]["color"][3]*1.0),
        fontSize: p_templateMap[fieldName]["fontStyle"]["size"]*1.0,
        fontFamily: _ts.fontFamily,
    );
    // get the text data
    String data = getFieldData(fieldName);
    return Positioned(
          left: p_templateMap[fieldName]["position"][0]*width,
          top: p_templateMap[fieldName]["position"][1]*height,
          child: GestureDetector(
            onLongPress: (){
              openBottomSheet(context, EditFont(selected: fieldName, fontStyle: p_templateMap[fieldName]["fontStyle"]!));
            },
            child: Draggable(
                maxSimultaneousDrags: 1,
                onDragUpdate: (details){
                   // simultaneously update hte data with this
                  try {
                    double dx = (p_templateMap[fieldName]["position"][0])*width+details.delta.dx;
                    double dy = (p_templateMap[fieldName]["position"][1])*height+details.delta.dy;
                    double margin =  small*p_templateMap[fieldName]["fontStyle"]["size"]*1.0;
                    // limiting values
                    if(dx>width-margin*0.05) {dx = width - margin*0.05;}
                    if(dy>height-margin*0.07) {dy = height - margin*0.07;}
                    if(dx<-margin*0.01) {dx = -margin*0.01;}
                    if(dy<-margin*0.08) {dy = -margin*0.08;}
                    setState(() {
                      p_templateMap[fieldName]["position"] = [dx/width,dy/height];
                    });
                  } catch (e) {
                    logger.e("piop $e");
                  }
                },
                onDragEnd: (d){
                  // finally add the details in tempData of the card
                  Provider.of<TemplateData>(context,listen: false).updatePositioning(fieldName, p_templateMap[fieldName]["position"]);
                },
                feedback: Center(),
                child: Text(data,style: _style)),
          ));
  }
  Map<String, dynamic>? getAllPositions(CardData? cardData) {
    String pathMyCards = getCardImagePath(cardName: cardData!.cardName , isMine: true); // directory where this card is saved
    String pathTemplates = getTemplateLocalPath(
        key: "config",
        fileName: "config1",
        tempSubPath: getTemplateSubPath(cardData: cardData, forLocal: true,code: p_imageAsTemplateCode)!);
    String? _path;
    Map<String, dynamic>? _map;
    Map<String, dynamic>? _defaultMap = {
      "templateType": "jpg",
      "editable": true,
      "front": {
        "email": {
          "position": [0.5, 0.5],
          "lol":{}
        },
        "lol":"lol"
        ,},
      "back": {},
    };
    if(p_imageAsTemplateCode!=null) {
      // if the card is not template
      _defaultMap.addAll({"tempCode":p_imageAsTemplateCode});
      // return _defaultMap;
    }
    // check if the config1 file exists in local image path
    if (File("$pathMyCards/config1.json").existsSync()) {
      _path = "$pathMyCards/config1.json";
    } else if (File(pathTemplates).existsSync()) {
      // not then check if config1 file exists in templates folder
      _path = pathTemplates;
    }
    if (_path != null && _path != NO_IMAGE_FOUND) {
      // extract front and back from them
      _map = json.decode(File(_path).readAsStringSync());
    } else {
      if (isTemplate(cardData)) {
        _map = _defaultMap;
      }
      logger.e("unable to get positions map");
    }
    // _map!["front"]["title"]["fontStyle"]["size"] = 20;
    print("mmom $_map");
    cardData.templateName = _map;
    logger.i(cardData.getMapFromCardData());
    Provider.of<TemplateData>(context,listen: false).updateMyCardTempData(cardData);
    return _map;
  }
}
triggerSnackbarForFontNotFound(String fieldName) async{
  await Future.delayed(Duration(seconds: 1));
  if(!isTriggered)AlacardSnackBar(bc_manageCardContext, "${p_templateMap[fieldName]["fontStyle"]["fontFamily"]} font is not fount!",duration: Duration(seconds: 1));
  isTriggered = true;
}