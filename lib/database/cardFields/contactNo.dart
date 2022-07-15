import 'package:alacard_template/constants.dart';
import 'package:alacard_template/functions.dart';

class ContactNo {
  String countryCode;
  String number;
  String type;
  bool isVerified;

  ContactNo(
      {this.countryCode = defaultCountryCode,
      this.type = "Personal",
      this.isVerified = false,
      required this.number});

  String toStringWithSeparator() {
    return this.countryCode+
        propertiesSeparator +
        this.number+
        propertiesSeparator +
        this.type+
        propertiesSeparator +
        this.isVerified.toString();
  }
}
