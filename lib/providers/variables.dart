import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/database/cardFields/contactNo.dart';
import 'package:alacard_template/database/cardFields/customField.dart';
import 'package:alacard_template/database/cardFields/socialMedia.dart';
import 'package:alacard_template/database/sharingPreferences.dart';
import 'package:flutter/material.dart';

class Variables extends ChangeNotifier {
  UiModes? uiMode;
  bool _isMinimal = !false;
  Map<CardFace, bool> _areCardImagesEdited = {
    CardFace.front: false,
    CardFace.back: false,
    CardFace.icon: false
  };
  // so that all values are same across whole app
  SharingPreferences _sharingPrefs = SharingPreferences();
  //used to store data while adding a new card
  CardData _tempCardDetails = CardData();

  //for updating profile link while editing social media
  String _profileLink = "";
  //getters
  bool get isMinimal => _isMinimal==true;
  Map<CardFace, bool> get areCardImagesEdited => Map.from(_areCardImagesEdited);
  SharingPreferences get sharingPrefs {
    String ss = _sharingPrefs.sharingPreferencesToString();
    return getSharingPreferenceFromString(ss);
  }
  CardData get tempCardDetails  {
      Map<String,String?> m =  _tempCardDetails.getMapFromCardData();
      late CardData c = CardData();
      c.getCardDataFromMap(m);
      return c;
  }
  String get profileLink => _profileLink.toString();
  //reset for logout
  void resetAll(){
    uiMode = null;
    _isMinimal = true;
    _areCardImagesEdited = {
      CardFace.front: false,
      CardFace.back: false,
      CardFace.icon: false
    };
    _sharingPrefs = SharingPreferences();
    _tempCardDetails = CardData();
    _profileLink = "";
  }
  //update theme mode
  void updateTheme(UiModes newValue , {doNotify = true}) {
    if(uiMode!=newValue) {
      uiMode = newValue;
      if(doNotify)notifyListeners();
    }
  }
  //update is minimal
  void updateIsMinimal(bool newValue, {doNotify = true}) {
    if(_isMinimal!=newValue) {
      _isMinimal = newValue;
      if(doNotify)notifyListeners();
    }
  }
  //update theme mode
  void updateSharingPrefs(SharingPreferences newValue, {doNotify = true}) {
      _sharingPrefs = newValue;
      if(doNotify)notifyListeners();
  }

  //update are card images editted
  void updateAreImagesEdited(CardFace cardFace , {doNotify = true}) {
      _areCardImagesEdited.addAll({cardFace: true});
      logger.i("the are images editted = $areCardImagesEdited");
      if(doNotify)notifyListeners();
  }
  void resetImagesEdited() {
    _areCardImagesEdited = {
      CardFace.front: false,
      CardFace.back: false,
      CardFace.icon: false
    };
    notifyListeners();
  }

  //to edit contacts from bottom sheet
  void editTempCardContactDetails({required ContactNo contactNo, required CRUD crud, int index = 0}) {
    if (_tempCardDetails.contactNos == null) {
      _tempCardDetails.contactNos = [];
    }
    switch (crud) {
      case CRUD.create:
        _tempCardDetails.contactNos!.add(contactNo);
        break;
      case CRUD.update:
        _tempCardDetails.contactNos![index] = contactNo;
        break;
      case CRUD.delete:
        _tempCardDetails.contactNos!.removeAt(index);
        break;
      default:
        break;
    }

    notifyListeners();
  }

  //to edit social from bottom sheet
  void editTempCardSocialDetails(
      {required SocialMedia socialMedia, required CRUD crud, int index = 0}) {
    if (_tempCardDetails.socialMedias == null) {
      _tempCardDetails.socialMedias = [];
    }
    switch (crud) {
      case CRUD.create:
        _tempCardDetails.socialMedias!.add(socialMedia);
        break;
      case CRUD.update:
        _tempCardDetails.socialMedias![index] = socialMedia;
        break;
      case CRUD.delete:
        _tempCardDetails.socialMedias!.removeAt(index);
        break;
      default:
        break;
    }

    notifyListeners();
  }

  //to edit social from bottom sheet
  void editTempCardCustomFields(
      {required CustomField customField, required CRUD crud, int index = 0}) {
    if (_tempCardDetails.customFields == null) {
      _tempCardDetails.customFields = [];
    }
    switch (crud) {
      case CRUD.create:
        _tempCardDetails.customFields!.add(customField);
        break;
      case CRUD.update:
        _tempCardDetails.customFields![index] = customField;
        break;
      case CRUD.delete:
        _tempCardDetails.customFields!.removeAt(index);
        break;
      default:
        break;
    }

    notifyListeners();
  }
  // edit the note
  void editTempCardNote(String newValue){
    if(newValue!=(_tempCardDetails.note??"")){
      _tempCardDetails.note = newValue;
    }
  }
  // update profile link
  void setProfileLink(String newValue){
    if(newValue!=_profileLink){
      _profileLink = newValue;
      notifyListeners();
    }
  }
  void updateTempCard(CardData newValue){
    if(_tempCardDetails!=newValue){
      _tempCardDetails = newValue;
      notifyListeners();
    }
  }
  void clearTempCard(){
    _tempCardDetails = CardData();
    notifyListeners();
  }
}
