import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/database/cardFields/contactNo.dart';
import 'package:flutter/material.dart';

class TemplateData extends ChangeNotifier {
  CardData? _myCardTempData;
  List<String>? _displayList;
  // getters
  CardData? get myCardTempData {
    if (_myCardTempData != null){
     Map<String,String?> m =  _myCardTempData!.getMapFromCardData();
     late CardData c = CardData();
     c.getCardDataFromMap(m);
     return c;
    }
    else {
      return null;
    }
  }
  Map<String,String?>? tempCardMapData() {
    if (_myCardTempData != null){
     Map<String,String?> m =  _myCardTempData!.getMapFromCardData();
     return m;
    }
    else {
      return null;
    }
  }

  List<String>? get displayList =>_displayList!=null?List<String>.from(_displayList!):null;

  updateMyCardTempData(CardData? newValue){
    _myCardTempData = newValue;
    // notifyListeners();
  }
  updateFontStyle(String fieldName,Map<String,dynamic> newValue) {
    if(_myCardTempData!.templateName!["front"][fieldName]==null){
      _myCardTempData!.templateName!["front"][fieldName] = {
        "position": [0.5, 0.5],
        "fontStyle": {"bold": false,"fontFamily": "Roboto","color": [255,255,255,1],"size": 10.0},
      };
    }
    _myCardTempData!.templateName!["front"][fieldName]["fontStyle"] = newValue;
    notifyListeners();
  }
  updatePositioning(String fieldName,List<dynamic> newValue) {
    try {

      logger.e("piop piop $newValue ${_myCardTempData!.templateName!["front"][fieldName]}");
      if(_myCardTempData!.templateName!["front"][fieldName]==null){
        _myCardTempData!.templateName!["front"][fieldName] = {
          "position": [0.5, 0.5],
          "fontStyle": {"bold": false,"fontFamily": "Roboto","color": [255,255,255,1],"size": 10.0},
        };
      }

      _myCardTempData!.templateName!["front"][fieldName]["position"] = newValue;
      notifyListeners();
    } catch (e) {
      logger.e(e);
    }
  }
  updateDisplayList(CRUD crud , {required List<String> newValues, notify = true}){
    try {
      if(_displayList==null)_displayList = [];

      switch(crud){
            case CRUD.update:
              _displayList!.addAll(newValues);
              break;
            case CRUD.delete:
              if(newValues[0]=="all"){
                _displayList = [];
              } else {
                newValues.forEach((fieldName) {
                  _displayList!.remove(fieldName);
                });
              }
              break;
            default: logger.e("unable to update display list ");
          }

      if(notify)notifyListeners();
    } catch (e) {
      logger.e(e);
    }
  }


}