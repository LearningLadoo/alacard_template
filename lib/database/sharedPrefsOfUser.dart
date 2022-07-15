import 'dart:developer';

import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/sharingPreferences.dart';
import 'package:alacard_template/functions.dart';

enum GuideScreen{
  dashboard,
  menu,
  share,
  imageUploadAsTemplate,
  template
}
class SharedPrefsOfUser {
  String? email , pass;
  List<String?> pendingUIDs;
  Map<GuideScreen, bool>? screenGuide;
  SharingPreferences? sharingPreferences;
  UiModes themeMode;
  bool isMinimal;

  SharedPrefsOfUser(
      {this.email,
      this.pass,
      this.pendingUIDs = const [],
      this.screenGuide,
      this.sharingPreferences,
      this.themeMode = UiModes.dark,
      this.isMinimal = false}) {
    //to setup screenGuide
    initialGuideMap();
  }
  SharedPrefsOfUser clone(){
    return new SharedPrefsOfUser(
      email: this.email,
      pass: this.pass,
      pendingUIDs: this.pendingUIDs,
      screenGuide: this.screenGuide,
      sharingPreferences: this.sharingPreferences,
      themeMode: this.themeMode,
      isMinimal: this.isMinimal
    );
  }
  Map<String, String> getMapFormSharedPrefs() {

    return {
      "email": this.email.toString(),
      "pendingUIDs": pendingUIDsToString(),
      "screenGuide": screenGuideToString(),
      "sharingPreferences": this.sharingPreferences!=null?this.sharingPreferences!.sharingPreferencesToString():"null",
      "themeMode" : this.themeMode.toString(),
      "isMinimal" : this.isMinimal.toString(),
    };
  }
  String pendingUIDsToString(){
    String temp = "";
    this.pendingUIDs.forEach((element) {
      if(!(element==null||element=="")) {
        temp = temp + sameFieldSeparator + element;
      }
    });
    return temp;
  }
  String screenGuideToString(){
    String temp = "";
    for(GuideScreen guideScreen in GuideScreen.values){
      temp = temp+this.screenGuide![guideScreen].toString()+((GuideScreen.values.last!=guideScreen)?sameFieldSeparator:"");
    }
    return temp;
  }
  initialGuideMap() {
    if(this.screenGuide==null){this.screenGuide = {};}
    if(this.screenGuide!={})return;
    for (GuideScreen guideScreen in GuideScreen.values) {
      this.screenGuide!.addAll({guideScreen: false});
    }
  }
}
SharedPrefsOfUser getSharedPrefsFromMap(Map<String,dynamic> _map){
  print("pop email is ${_map}");
  return SharedPrefsOfUser(
    email: _map["email"],
    pass: _map["pass"],
    isMinimal: _map["isMinimal"] == "true",
    themeMode: getThemeModeFromString(_map["themeMode"]!) ?? UiModes.auto,
    sharingPreferences : getSharingPreferenceFromString(_map["sharingPreferences"]!),
    pendingUIDs: getPendingUIDsFromString(_map["pendingUIDs"]!),
    screenGuide: getScreenGuideFromString(_map["screenGuide"]!),
  );
}
List<String?> getPendingUIDsFromString(String string){
  print("qpq2 $string");
  if(string=="")return[];
  return string.split(sameFieldSeparator);
}
Map<GuideScreen, bool> getScreenGuideFromString(String string){
  Map<GuideScreen, bool> temp = {};
  List<String> list = string.split(sameFieldSeparator);
  List<GuideScreen> guide = GuideScreen.values;
  for(int i=0;i<guide.length;i++){
    temp.addAll({guide[i]:list[i]=="true"});
  }
  return temp;
}