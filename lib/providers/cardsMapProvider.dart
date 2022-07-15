
import 'package:alacard_template/database/cardData.dart';
import 'package:flutter/cupertino.dart';

class CardsMapProvider extends ChangeNotifier {
  Map<String, CardData> _userCardsMap = {};
  bool isBackupNeeded = false;
// getters
  Map<String, CardData> get userCardsMap {
    return Map.from(_userCardsMap);
  }
  void resetAll(){
    _userCardsMap = {};
  }
  void insertFromUserCardsMap(CardData card) {
    //get cardName and the card should be real
    //adds the card or insert the values
    _userCardsMap.addAll({card.cardName!: card});
    notifyListeners();
  }

  void deleteFromUserCardsMap(CardData card) {
    _userCardsMap.remove(card.cardName);
    notifyListeners();
  }
  void updateUserCardsMap(Map<String,CardData> newValues){
    _userCardsMap.clear();
    _userCardsMap.addAll(newValues);
    newValues.forEach((key, value) {
      if(isBackupNeeded==false&&(value.isUpdated==null||value.isUpdated==false))isBackupNeeded=true;
    });
    notifyListeners();
  }
  updateIsBackupNeeded(bool newValue){
    if(isBackupNeeded!=newValue) {
      isBackupNeeded = newValue;
      notifyListeners();
    }
  }
}
