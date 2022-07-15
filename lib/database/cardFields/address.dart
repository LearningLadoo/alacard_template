import 'package:alacard_template/constants.dart';

class Address {
  String address;
  bool allowMap;
  List<double> position;

  Address(
      {required this.address,
      this.allowMap = false,
      this.position = const [0, 0]});


  String toStringWithSeparator() {
    return this.address +
        propertiesSeparator +
        this.allowMap.toString() +
        propertiesSeparator +
        this.position[0].toString() +
        propertiesSeparator +
        this.position[1].toString();
  }
}
