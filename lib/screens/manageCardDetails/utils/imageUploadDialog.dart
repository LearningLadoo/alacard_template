import 'dart:io';

import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/template/chooseTemplates.dart';
import 'package:alacard_template/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageUploadDialog extends StatefulWidget {
  BuildContext loaderContext;
  CardFace? cardFace;
  CardData? cardData;
  bool isMine ;
  ImageUploadDialog(this.loaderContext,{this.cardFace, this.cardData,this.isMine = false});
  @override
  _ImageUploadDialogState createState() => _ImageUploadDialogState();
}

class _ImageUploadDialogState extends State<ImageUploadDialog> {
  bool checkboxValue = false;
  late CardFace? cardFace;
  late bool isMine;
  @override
  void initState() {
    cardFace = widget.cardFace;
    isMine = widget.isMine;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
        width: deviceWidth - large,
        decoration: BoxDecoration(
        color: themeData.backgroundColor,
        borderRadius: BorderRadius.circular(small),
    ),
      padding: EdgeInsets.all(small*2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Insert Image From",
            style: themeData.textTheme.headline2,
          ),
           (isMine && cardFace==CardFace.front)?Container(
            width: deviceWidth-large,
            height: medium*2.5,
            child: CheckboxListTile(
                title: Text(
                    "Mark as Editable",
                    style: themeData.textTheme.subtitle1
          ),
          value: checkboxValue,
          activeColor: themeData.colorScheme.onPrimary,
          onChanged:(newValue){
            logger.i("the checkbox = $newValue");
            setState(() {
              checkboxValue = newValue??false;
            });
            if(checkboxValue){
              p_imageAsTemplateCode = (checkboxValue)?getNewMyImageTemplateId(widget.cardData):null;
              logger.i("the new $p_imageAsTemplateCode");
            } else {
              p_imageAsTemplateCode = null;
            }
          }),
    ):Spacing().mediumWidget,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ButtonType3(
                height: medium*1.2,
                width: isMine?large*2.5:large*2.2,
                text: "Gallery",
                offset: 0,
                themeData: themeData,
                isbnw: true,
                bgColor: themeData.colorScheme.onPrimary.withOpacity(0),
                onPressed: () async {
                  await getImage(widget.loaderContext, cardFace,source: "gallery",isMine: isMine);
                  Navigator.pop(bc_alacardDialogContext);
                },
              ),
              if(!isMine)ButtonType3(
                height: medium*1.2,
                width: large*2.2,
                text: "Camera",
                offset: 0,
                themeData: themeData,
                isbnw: true,
                bgColor: themeData.colorScheme.onPrimary,
                onPressed: () async {
                  await getImage(widget.loaderContext, cardFace,source: "camera",isMine: isMine);
                  Navigator.pop(bc_alacardDialogContext);
                },
              ),
            ],
          ),
          if(isMine)
            OrDivider(themeData),
          if(isMine) Spacing().smallWiget,
          if(isMine)
            ButtonType3(
              height: medium*1.2,
              width: large*2.7,
              text: " Use Template",
              offset: 0,
              themeData: themeData,
              isbnw: true,
              bgColor: themeData.colorScheme.onPrimary,
              onPressed: () async {
                // open another pop up with all the templates
                AlacardDialog(
                  context,
                  child: ChooseTemplates(),
                );
              },
            ),
          OrDivider(themeData),
          Spacing().smallWiget,
          ButtonType3(
            height: medium*1.2,
            width: large*2.5,
            text: " Delete ${cardFaceToString(cardFace)}",
            offset: 0,
            themeData: themeData,
            isbnw: true,
            bgColor: themeData.colorScheme.onPrimary,
            onPressed: () async {
              String path = getImagePath(cardFace: cardFace , isMine: isMine);
              if(File(path).existsSync()) {
                // mark it edited and delete the temp.
                Provider.of<Variables>(context, listen: false).updateAreImagesEdited(cardFace ?? CardFace.front);
                // now delete temp
                File(path).deleteSync(recursive: true);
                // while saving if no temp image is found then delete the current saved or template
              }
              Navigator.pop(bc_alacardDialogContext);
            },
          ),
        ],
      ),
    );
  }
}