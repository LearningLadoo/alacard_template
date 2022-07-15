import 'package:alacard_template/constants.dart';

class CustomField {
  String infoType;
  String heading;
  dynamic fieldData; //this could be text, email, date or address

  CustomField({this.infoType = "Text",required this.heading, this.fieldData});

  String toStringWithSeparators() {
    String fd;
    switch (this.infoType) {
      case "Address":
        fd = this.fieldData.toStringWithSeparator();
        break;
      default:
        fd = this.fieldData;
    }
    return this.infoType + typeSeparator + this.heading+
        typeSeparator + fd;
  }
  void printAllData(){
    print("infoType = $infoType , heading = $heading , fieldData = $fieldData");
  }
}
