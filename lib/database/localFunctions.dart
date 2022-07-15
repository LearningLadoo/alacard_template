import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardFields/address.dart';
import 'package:alacard_template/database/cardFields/customField.dart';
import 'package:alacard_template/database/cardFields/socialMedia.dart';
import 'package:alacard_template/database/cardFields/updateHistory.dart';
import 'package:alacard_template/database/sharedPrefsOfUser.dart';
import 'cardFields/contactNo.dart';

// dealing with contacts
String contactNosToString(List<ContactNo> contactNos) {
  String tempString = "";
  for (ContactNo _contactNo in contactNos) {
    if (tempString != "") tempString += sameFieldSeparator;
    tempString += _contactNo.toStringWithSeparator();
  }
  return tempString;
}

List<ContactNo> stringToContactNos(String? value) {
  List<ContactNo> contactNos = [];
  if (value!=null&&value!="") {
    //print(" ----2-1-1");
    for (String i in value.split(sameFieldSeparator)) {
      //print(" ----2-1-2");
        contactNos.add(ContactNofromString(i));
      }
    //print(" ----2-1-3");
  }
  return contactNos;
}

ContactNo ContactNofromString(String value) {
  List<String> values = value.split(propertiesSeparator);
  //print(" ----2-1-2-1 $values");
  return ContactNo(
      countryCode: values[0],
      number: values[1],
      type: values[2],
      isVerified: values[3] == "true");
}

// dealing with social media
String socialMediasToString(List<SocialMedia> socialMedias) {
  String tempString = "";
  for (SocialMedia socialMedia in socialMedias) {
    if (tempString != "") tempString += sameFieldSeparator;
    tempString += socialMedia.toStringWithSeparator();
  }
  return tempString;
}

List<SocialMedia> stringToSocialMedias(String? value) {
  List<SocialMedia> socialMedias = [];
  if (value!=null&&value!="") {
    for (String i in value.split(sameFieldSeparator)) {
        socialMedias.add(SocialMediafromString(i));
      }
  }
  return socialMedias;
}

SocialMedia SocialMediafromString(String value) {
  List<String> values = value.split(propertiesSeparator);
  return (SocialMedia(
      type: values[0],
      username: values[1],
      profileLink: values[2],
      isVerified: values[3] == "true"));
}

// dealing with custom fields
String customFieldsToString(List<CustomField> customFields) {
  String tempString = "";
  for (CustomField customField in customFields) {
    if (tempString != "") tempString += sameFieldSeparator;
    tempString += customField.toStringWithSeparators();
  }
  return tempString;
}

List<CustomField> stringToCustomFields(String? value) {
  //print("string to custom field");
  List<CustomField> customFields = [];
  if (value!=null&&value!="") {
    for (String field in value.split(sameFieldSeparator)) {
        customFields.add(customFieldFromString(field));
      }
  }
  return customFields;
}

CustomField customFieldFromString(String value) {
  //type^heading^fielddata
  // fielddata = property1#property2#property
  List<String> customFieldData = value.split(typeSeparator);
  String type = customFieldData[0];
  String heading = customFieldData[1];
  String fieldData = customFieldData[2];

  switch (type) {
    case "Address":
      stringToAddress(fieldData);
      break;
    default:
      break;
  }
  return CustomField(infoType: type, heading: heading, fieldData: fieldData);
}
//date and time updates
String updatesHistoryToString(List<UpdateHistory?> list){
  String tempString = "";
  if (list.isNotEmpty) {
    for (UpdateHistory? updateHistory in list) {
        if (tempString != "") tempString += sameFieldSeparator;
        tempString += updateHistory!.toStringWithSeparator();
      }
  }
  return tempString;
}

List<UpdateHistory> stringToUpdatesHistory(String? value){
  //print("string to update History");
  List<UpdateHistory> temp = [];
  if(value!=null&&value!=""){
    for(String string in value.split(sameFieldSeparator)){
      temp.add(UpdateHistoryfromString(string));
    }
  }
  return temp;
}
UpdateHistory UpdateHistoryfromString(String value) {
  List<String> values = value.split(propertiesSeparator);
  return UpdateHistory(int.parse(values[0]),values[1]);
}

//address
Address? stringToAddress(String? value) {
  if (value!=null&&value!="") {
    List<String> values = value.split(propertiesSeparator);
    return Address(
        address: values[0],
        allowMap: values[1] == "true",
        position: [double.parse(values[2]), double.parse(values[3])]);
  } else {
    //print("String to address %");
    return null;
  }
}

CardType getCardTypeFromString(String? string){
  //print("string to CardType");
  CardType temp;
  if(string==CardType.received.toString()){
    temp = CardType.received;
  }else if(string==CardType.manuallyAdded.toString()){
    temp = CardType.manuallyAdded;
  }else if(string==CardType.mine.toString()){
    temp = CardType.mine;
  }else{
    //default case
    temp = CardType.manuallyAdded;
  }
  return temp;
}
