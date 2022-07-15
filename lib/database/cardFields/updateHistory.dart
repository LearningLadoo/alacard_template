import 'package:alacard_template/constants.dart';

class UpdateHistory{
  int epoch;
  String tag = "";
  UpdateHistory(this.epoch,this.tag);

  String toStringWithSeparator(){
    return epoch.toString()+propertiesSeparator+tag;
  }
}