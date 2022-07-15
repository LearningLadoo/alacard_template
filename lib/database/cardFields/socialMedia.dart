import 'package:alacard_template/constants.dart';

class SocialMedia {
  String username;
  String type;
  String? profileLink;
  bool isVerified;

  SocialMedia({required this.username, required this.type , this.isVerified = false, this.profileLink});


  String toStringWithSeparator() {
    return this.type+
        propertiesSeparator +
        this.username+
        propertiesSeparator +
        (this.profileLink??"") +
        propertiesSeparator +
        this.isVerified.toString();
  }
}
