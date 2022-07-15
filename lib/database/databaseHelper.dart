import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/providers/cardsMapProvider.dart';
import 'package:alacard_template/providers/templateData.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DatabaseHelper{
  BuildContext? context; // if the context is null then all the operations will not be for providers
  late CardsMapProvider _cardsMapProvider;
  late Variables _variablesProvider;
  DatabaseHelper(this.context) {
    if(this.context !=null) {
      _cardsMapProvider = Provider.of<CardsMapProvider>(context!, listen: false);
      _variablesProvider = Provider.of<Variables>(context!, listen: false);
    }
  }
  Future addCardOnDevice(CardData cardData) async {
    if(cardData.imageTokens==null){
      cardData.imageTokens =  {CardFace.front: null,CardFace.back: null,CardFace.icon: null};
    }
    cardData.isUpdated = false;//its for updated in cloud
    if(cardData.cardType == CardType.mine){
      // add template config files and images
      if(isTemplate(cardData)){
        // config1
        logger.i("the template name is = ${cardData.templateName}");
        if(cardData.templateName!["tempCode"] == null && p_imageAsTemplateCode!=null){
          // card image is selected here
          cardData.templateName!["tempCode"] = p_imageAsTemplateCode;
          p_imageAsTemplateCode = null;
        }
        Map<String,dynamic> _map = cardData.templateName!;
        _map.addAll({"frontDisplay":Provider.of<TemplateData>(this.context!,listen: false).displayList });
        logger.i("the map isssss $_map");
      }
      //update sql
      await p_sqlManager.myCards_addCard(cardData);
      saveManualCardImages(cardData, _variablesProvider.areCardImagesEdited);
      //update provider
      //logger.i(cardData.getMapFromCardData());
      _cardsMapProvider.insertFromUserCardsMap(cardData);
      //backup
      _cardsMapProvider.updateIsBackupNeeded(true);
    }
    logger.i("${cardData.cardName} : cardData after adding to local = ${cardData.getMapFromCardData()}");
  }
  Future getAllCardsFromLocalDatabase()async{
    Map<String, CardData>_map = await p_sqlManager.myCards_getAllCards();
    _cardsMapProvider.updateUserCardsMap(_map);
  }
  Future updateCard(CardData cardData)async{
    // card should be unProcessed
    String? _tempCode;
    logger.i("geeg 1 ${cardData.templateName} and $p_imageAsTemplateCode");
    cardData.isUpdated = false;//its for updated in cloud
    bool isTemplateCard = isTemplate(cardData);
    dynamic imagesEdits = _variablesProvider.areCardImagesEdited;
    logger.i("geeg 2 ${cardData.templateName}");
    //putting mark for unfinished
    imagesEdits.forEach((face,isUpdated) {
      String token= cardData.imageTokens![face]??"null";
      if(isUpdated&&!token.startsWith(unfinished)){
       cardData.imageTokens!.addAll({face: (unfinished + token).toString()});
      }
    });
    logger.i("geeg 3 ${cardData.imageTokens}");
    if(cardData.cardType == CardType.mine){
      logger.i("geeg 4 ${cardData.templateName}");
      // add template config1 file
      if(isTemplateCard){
        logger.i("geeg 5 ${cardData.templateName}");
        if(p_imageAsTemplateCode!=null){
          // card image is selected here
          cardData.templateName!["tempCode"] = p_imageAsTemplateCode;
          _tempCode = p_imageAsTemplateCode;
          cardData.templateName!["source"] = "personal";
          logger.i("geeg 8 ${cardData.templateName}");
          // _cardsMapProvider.insertFromUserCardsMap(cardData);
          p_imageAsTemplateCode = null;
        }
        logger.i("geeg 6 ${cardData.templateName}");
        Map<String,dynamic> _map = cardData.templateName!;
        _map.addAll({"display":Provider.of<TemplateData>(this.context!,listen: false).displayList });
        // todo do it properly for all type of config files in future
        String path = "${getCardImagePath(cardName: cardData.cardName,isMine: true)}/config1.json";
        logger.i("the map isssss $_map and ttt $path");
        logger.i("geeg 7 ${cardData.templateName}");
        File(path).writeAsStringSync(json.encode(_map));
        // add config1 file for template if it doesn't exists
        String tempPath = getTemplateLocalPath(tempSubPath: getTemplateSubPath(cardData: cardData,forLocal: true,code: p_imageAsTemplateCode)! , key: "json",fileName: "config1");
        if(!File(tempPath).existsSync()){
          if(_map["tempCode"].contains(unfinished)){
            _map.addAll({"tempCode": _map["tempCode"].replaceAll(unfinished,"")});
          }
          File(tempPath).writeAsStringSync(json.encode(_map));
        }
        logger.i("geeg 8 ${cardData.templateName}");
      }
      if(_tempCode!=null){
        cardData.templateName!["tempCode"] = _tempCode;
      }
      // store images
      dynamic ret = await saveManualCardImages(cardData, imagesEdits, isMine: true);
      logger.wtf("geeg 9 $ret");
      _cardsMapProvider.insertFromUserCardsMap(cardData);
      //update sql
      logger.i("geeg 10 ${cardData.getMapFromCardData()}");
      await p_sqlManager.myCards_updateCard(cardData);
      logger.i("geeg 11 ${cardData.getMapFromCardData()}");// image token is now processed
    }
    _variablesProvider.resetImagesEdited();
    //backup
    _cardsMapProvider.updateIsBackupNeeded(true);
  }
  Future setupNewMyCard(int cardNo)async{
    try {
      CardData cd = CardData(
        cardName: "${cardNo}XX",
        dateTimeCreated: DateTime.now(),
        dateTimeUpdated: DateTime.now(),
        email: email,
        globalId: uid,
        cardType: CardType.mine
      );
      await addCardOnDevice(cd);
    } catch (e) {
      log("unable to setup new card! $e");
    }
  }
}
// Navigator.pushAndRemoveUntil(bc_currContext??bc_dashboardContext!,MaterialPageRoute(builder: (BuildContext context) => MainApp()),(Route<dynamic> route) => false);
