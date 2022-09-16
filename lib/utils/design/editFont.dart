import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/database/cardFields/contactNo.dart';
import 'package:alacard_template/database/cardFields/socialMedia.dart';
import 'package:alacard_template/providers/templateData.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/design/chooseFontFamily.dart';
import 'package:alacard_template/utils/design/colorPickerButton.dart';
import 'package:alacard_template/utils/common/incrementButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';
import 'package:provider/provider.dart';

class EditFont extends StatefulWidget {
  String selected;
  Map<String,dynamic> fontStyle;
  EditFont({required this.selected, required this.fontStyle});
  @override
  _EditFontState createState() => _EditFontState();
}

class _EditFontState extends State<EditFont> {
  late String selected ,tempValue;
  late Map<String,dynamic> fontStyle;
  late TemplateData _templateDataProvider, _templateDataProviderNotListen;
  late CardData cardData;
  @override
  void initState() {
    selected = widget.selected;
    fontStyle = widget.fontStyle;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
      PickerFont _font;
    try {
      _font = PickerFont(fontFamily: fontStyle["fontFamily"]);
    } catch (e) {
      _font = PickerFont(fontFamily: "Roboto");
        print(e);
    }
      _templateDataProviderNotListen= Provider.of<TemplateData>(bc_currContext!,listen: false);
      cardData = _templateDataProviderNotListen.myCardTempData!;

      if(selected == "contactNos"){
        tempValue = contactFieldString();
      }
      else if(selected == "socialMedias"){
        tempValue = socialFieldString();
      } else{
        tempValue = cardData.getMapFromCardData()[selected]??selected;
      }
      return Container(
        margin: EdgeInsets.fromLTRB(small, small, small, small),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // sample widget
            Text("Sample",style: themeData.textTheme.subtitle2,),
            Center(child: fieldWidget(selected, tempValue, fontStyle)),
            Divider(),
            Wrap(
              spacing: tiny,
              runSpacing: tiny,
              children: [
                ChooseFontFamily(
                    onSelect: (PickerFont font){
                      setState(() {
                        _font = font;
                        fontStyle["fontFamily"] = font.fontFamily;
                      });
                      logger.i("unu = ${font.fontFamily}");
                    },
                    height: medium*1.5,
                    width: deviceWidth-medium,
                    font: _font,
                ),
                ColorPickerButton(
                    height: medium*1.5,
                    initialColor: Color.fromRGBO(fontStyle["color"][0], fontStyle["color"][1], fontStyle["color"][2], fontStyle["color"][3]*1.0),
                    onSelect: (Color color){
                      List<dynamic> _rgboList = [color.red,color.green,color.blue,color.opacity];
                      setState(() {
                        fontStyle["color"] = _rgboList;
                      });
                }),
                IncrementButton(
                     height:medium*1.5,
                     width:0,
                     value:fontStyle["size"]*1.0,
                     max:100,
                     min:10,
                     isDouble: false,
                     factor:1,
                     tag:"Size",
                     onEdit:(value){
                            setState(() {
                              fontStyle["size"] = value;
                            });
                        })
              ],
            ),
            SizedBox(height: small*1.5,),
            Align(
              alignment: Alignment.bottomRight,
              child: ButtonType3(
                width: 6*small,
                height: medium*1.5,
                onPressed: () {
                  logger.i("the finsl font style is $fontStyle");
                  // update the template card data
                  _templateDataProviderNotListen.updateFontStyle(selected,fontStyle);
                  Navigator.pop(context);
                },
                themeData: Theme.of(context),
                text: "Save",
                bgColor: Theme.of(context).colorScheme.onPrimary,
                isbnw: true,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom != 0
                  ? MediaQuery.of(context).viewInsets.bottom
                  : 0,
            )
          ],
        ),
      );
  }
  String contactFieldString(){
    String cNo = "";
    if(cardData.contactNos!=null){
      String seperator = "\n";
      // if(positions!["Contactnos"]["organize"]["align"]==null||positions!["Contactnos"]["organize"]["align"]=="-"){
      //   seperator = ",";
      // }else{
      //   seperator = "\n";
      // }
      List<ContactNo> cList = cardData.contactNos!;
      for(ContactNo x in cList){
        cNo+="${x.countryCode} ${x.number}$seperator";
      }
    }
    return cNo;
  }
  String socialFieldString(){
    String cNo = "";
    if(cardData.socialMedias!=null){
      String seperator = "\n";
      // if(positions!["socialMedias"]["organize"]["align"]==null||positions!["socialMedias"]["organize"]["align"]=="-"){
      //   seperator = " ";
      // }else{
      //   seperator = "\n";
      // }
      List<SocialMedia> cList = cardData.socialMedias!;
      for(SocialMedia x in cList){
        cNo+="${x.username}$seperator";
      }
    }
    return cNo;
  }

  Widget fieldWidget(String fieldName , dynamic data , Map<String,dynamic> fontStyle){
    Color defaultColor = Theme.of(context).iconTheme.color!;
    late TextStyle _style;
    logger.i("font style $fontStyle");
      if(fontStyle["size"]==null) {
        fontStyle["size"] = 13;
      }
      if(fontStyle["color"]==null) {
        fontStyle["color"] = [defaultColor.red,defaultColor.blue,defaultColor.green,defaultColor.alpha];
      }
      if(fontStyle["fontFamily"]==null) {
        fontStyle["fontFamily"] = "Roboto";
      }

    try {
      _style = PickerFont(fontFamily: fontStyle["fontFamily"]).toTextStyle();
    } catch (e) {
      // todo displaySnackBar(context, "${_templateMap[fieldName]["fontStyle"]["fontFamily"]} font is not fount!");
      _style = Theme.of(context).textTheme.headline2!;
      logger.e(e);
    }_style = TextStyle(
        color:  Color.fromRGBO(fontStyle["color"][0], fontStyle["color"][1], fontStyle["color"][2], fontStyle["color"][3]*1.0),
        fontSize: fontStyle["size"]*1.0,
        fontFamily: _style.fontFamily,
        backgroundColor: Colors.transparent
    );

    return SizedBox(
        height: fontStyle["size"]*1.2,
        child: Text(data??fieldName,style: _style,));
  }
}
