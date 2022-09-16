import 'dart:io';
import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/providers/templateData.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/design/colorPickerButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditTemplate extends StatefulWidget {
  List<Color>? colors;
  EditTemplate({this.colors});
  @override
  _EditTemplateState createState() => _EditTemplateState();
}

class _EditTemplateState extends State<EditTemplate> {
  List<Color>? colors;
  late TemplateData _templateDataProviderNotListen;
  late CardData cardData;

  @override
  void initState() {
     colors = widget.colors;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    ThemeData themeData = Theme.of(context);
    _templateDataProviderNotListen= Provider.of<TemplateData>(bc_currContext!,listen: false);
    cardData = _templateDataProviderNotListen.myCardTempData!;

    return Container(
      margin: EdgeInsets.fromLTRB(screenWidth(context)/25,medium*1.1,screenWidth(context)/25,medium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Edit colors
          if(p_templateMap["colors"]!=null)Text("Edit Colors",style: themeData.textTheme.subtitle1,),
          // the color pallets
          if(p_templateMap["colors"]!=null)Padding(
            padding:  EdgeInsets.symmetric(vertical: small),
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: small,
              runSpacing: small,
              children: (p_templateMap["colors"].keys??[]).map<Widget>((k){
                print("yello $k");
                String hex = p_templateMap["colors"][k];
                if(hex=="")hex=k;
                return ColorPickerButton(
                  height:large,
                  initialColor: ColorFromHex(hex),
                  onSelect: (Color chosenColor){
                    setState((){
                      p_templateMap["colors"][k] = colorToHex(color: chosenColor,leadingHashSign: false);
                    });
                    cardData.templateName!["front"]["colors"]=p_templateMap["colors"];
                    _templateDataProviderNotListen.updateMyCardTempData(cardData,wannaNotify: true);},
                  title: "",);
              }).toList(),
            ),
          ),
          Divider(),
          if(!isBusinessCard(cardData))Padding(
            padding: EdgeInsets.symmetric(vertical: small),
            child: ButtonType3(
              width: deviceWidth-small,
              height: large-tiny,
              onPressed: () {
                logger.i("remove the template");
                if(isTemplate(cardData)){
                  // remove the config and front image file if it exists
                  String sub = getCardImagePath(isMine: true,cardName: cardData.cardName);
                  File _file = File(sub+"/config1.json");
                  logger.i("remove the config file at ${_file.path}");
                  if(_file.existsSync()){
                    logger.i("remove d config1 file");
                    _file.deleteSync(recursive: true);
                    // mark it edited and delete the temp file
                    Provider.of<Variables>(context,listen: false).updateAreImagesEdited(CardFace.front);
                    _file = File(getImagePath(cardFace: CardFace.front , isMine: true));
                    if(_file.existsSync()){
                      logger.i("remove d temp front file");
                      _file.deleteSync(recursive: true);
                    }
                  } else {
                    logger.e("remove the template failed");
                  }
                  cardData.templateName = null;
                  _templateDataProviderNotListen.updateMyCardTempData(cardData);
                  p_imageAsTemplateCode = null;
                }
                Navigator.pop(context);
              },
              themeData: Theme.of(context),
              text: " Remove this template",
              bgColor: Theme.of(context).colorScheme.onPrimary,
              isbnw: true,
            ),
          ),
        ],
      ),
    );
  }
}
