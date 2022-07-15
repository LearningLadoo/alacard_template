import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/localFunctions.dart';

import 'cardFields/address.dart';
import 'cardFields/contactNo.dart';
import 'cardFields/customField.dart';
import 'cardFields/socialMedia.dart';

class BusinessDetails {
  String? email, name, about;
  late String businessCode;//the business code
  List<ContactNo>? contactNos;
  List<SocialMedia>? socialMedias;
  Address? address;
  String? website;
  List<CustomField>? customFields;
  DateTime? dateTimeCreated;
  List<String> localEditable;
  bool isAuthentic;
  BusinessDetails(
      {this.email,
      this.name,
      this.about,
      required this.businessCode,
      this.contactNos,
      this.socialMedias,
      this.address,
      this.website,
      this.customFields,
      this.dateTimeCreated,
      this.localEditable= const ["name"],
      this.isAuthentic = false});
}
BusinessDetails getBusinessDetailsFromMap(Map<String,dynamic> tempMap){
  return BusinessDetails(
      email: tempMap["email"],
      name: tempMap["name"],
      about: tempMap["about"],
      businessCode: tempMap["businessCode"],
      contactNos: stringToContactNos(tempMap["contactNos"]),
      socialMedias: stringToSocialMedias(tempMap["socialMedias"]),
      address: stringToAddress(tempMap["address"]),
      website: tempMap["website"],
      customFields: stringToCustomFields(tempMap["customFields"]),
      dateTimeCreated: tempMap["dateTimeCreated"]!=null?DateTime.parse(tempMap["dateTimeCreated"]!):null,
      localEditable: tempMap["localEditable"]!=null?tempMap["localEditable"].split(sameFieldSeparator):[],
      isAuthentic: tempMap["isAuthentic"],
  );
}
