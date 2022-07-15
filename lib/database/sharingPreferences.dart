import 'package:alacard_template/constants.dart';

class SharingPreferences{
  String? defaultCardName;
  int sharingLimit ,sharingTime; // time in seconds
  bool dontAskBeforeSharing;
  bool bothWaysSharing;
  SharingPreferences({
    this.defaultCardName,
    this.dontAskBeforeSharing = false,
    this.sharingLimit = 1,
    this.sharingTime = 60,
    this.bothWaysSharing = false,
});
 String sharingPreferencesToString(){
   //null#true#1#60#false
    return this.defaultCardName.toString()+propertiesSeparator+this.dontAskBeforeSharing.toString()+propertiesSeparator+this.sharingLimit.toString()+propertiesSeparator+this.sharingTime.toString()+propertiesSeparator+this.bothWaysSharing.toString();
  }
}
SharingPreferences getSharingPreferenceFromString(String value){
  List<String> list = value.split(propertiesSeparator);
  print("qpq1");
  try {
    return SharingPreferences(
        defaultCardName: list[0],
        dontAskBeforeSharing: list[1]=="true",
        sharingLimit: int.parse(list[2]),
        sharingTime: int.parse(list[3]),
        bothWaysSharing: list[4]=="true",
      );
  } catch (e) {
    logger.e(e);
    return SharingPreferences();
  }
}