import 'dart:io';
import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/providers/templateData.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/utils/common/buttons.dart';
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
  late TemplateData _templateDataProvider, _templateDataProviderNotListen;
  late CardData cardData;
  @override
  void initState() {
     colors = widget.colors;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    // _templateDataProvider = Provider.of<TemplateData>(bc_mainContext);
    _templateDataProviderNotListen= Provider.of<TemplateData>(bc_currContext!,listen: false);
    cardData = _templateDataProviderNotListen.myCardTempData!;

    return Container(
      margin: EdgeInsets.fromLTRB(screenWidth(context)/25,medium,screenWidth(context)/25,medium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ButtonType3(
          //   width: 60,
          //   height: 40,
          //   onPressed: () {
          //     logger.i("saving the template");
          //     // update the template card data
          //     // _templateDataProviderNotListen.updateFontStyle(selected,fontStyle);
          //     Navigator.pop(context);
          //   },
          //   themeData: Theme.of(context),
          //   text: "save",
          //   bgColor: Theme.of(context).colorScheme.onPrimary,
          //   isbnw: true,
          // ),
          // if its not a business
          Row(
            children: [
              /*Wrap(
            children: [
              ColorPickerButton(30,Color.fromRGBO(fontStyle["color"][0], fontStyle["color"][1], fontStyle["color"][2], fontStyle["color"][3]*1.0),
                      (Color color){
                    List<dynamic> _rgboList = [color.red,color.green,color.blue,color.opacity];
                    setState(() {
                      fontStyle["color"] = _rgboList;
                    });
                  }),
              IncrementButton(30,110, fontStyle["size"]*0.1, 100, 10,1,"size",
                      (value){
                    setState(() {
                      fontStyle["size"] = value;
                    });
                  })
            ],
          ),*/
            ],
          ),
          if(!isBusinessCard(cardData))ButtonType3(
            width: deviceWidth-small,
            height: 4*small,
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

        ],
      ),
    );
  }
}
