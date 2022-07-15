import 'package:alacard_template/constants.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';

class ChooseFontFamily extends StatefulWidget {
  double height, width;
  Function onSelect;
  PickerFont? font;
  ChooseFontFamily({required this.onSelect,required this.height, required this.width,this.font});
  @override
  _ChooseFontFamilyState createState() => _ChooseFontFamilyState();
}

class _ChooseFontFamilyState extends State<ChooseFontFamily> {
  late PickerFont pickerFont;
  List<String> _myGoogleFonts = [
    "Abril Fatface",
    "Aclonica",
    "Alegreya Sans",
    "Architects Daughter",
    "Archivo",
    "Archivo Narrow",
    "Bebas Neue",
    "Bitter",
    "Bree Serif",
    "Bungee",
    "Cabin",
    "Cairo",
    "Coda",
    "Comfortaa",
    "Comic Neue",
    "Cousine",
    "Croissant One",
    "Faster One",
    "Forum",
    "Great Vibes",
    "Heebo",
    "Inconsolata",
    "Josefin Slab",
    "Lato",
    "Libre Baskerville",
    "Lobster",
    "Lora",
    "Merriweather",
    "Montserrat",
    "Mukta",
    "Nunito",
    "Offside",
    "Open Sans",
    "Oswald",
    "Overlock",
    "Pacifico",
    "Playfair Display",
    "Poppins",
    "Raleway",
    "Roboto",
    "Roboto Mono",
    "Source Sans Pro",
    "Space Mono",
    "Spicy Rice",
    "Squada One",
    "Sue Ellen Francisco",
    "Trade Winds",
    "Ubuntu",
    "Varela",
    "Vollkorn",
    "Work Sans",
    "Zilla Slab"
  ];
  @override
  void initState() {
    pickerFont = widget.font??PickerFont(fontFamily: "Roboto");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    Color color = themeData.scaffoldBackgroundColor;
    Color darkColor = getAdjustColor(color, -7 * (themeMode == ThemeMode.light ? 2 : 1));
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
        showDialog(
          barrierColor: themeData.colorScheme.secondary.withOpacity(0.5),
          context: context,
          builder: (context) {
            return AlertDialog(
                contentPadding: EdgeInsets.all(5.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(small),
                ),
                elevation: 0,
                insetPadding: EdgeInsets.zero,
                backgroundColor: themeData.scaffoldBackgroundColor,
                content: SingleChildScrollView(
                  child: Container(
                    height: deviceHeight*0.9,
                    width: deviceWidth*0.9,
                    child: FontPicker(
                      showInDialog: true,
                      onFontChanged: (font) {
                        setState(() {
                          pickerFont = font;
                        });
                        widget.onSelect(font);
                        print("${font.fontFamily} with font weight ${font.fontWeight} and font style ${font.fontStyle}. FontSpec: ${font.toFontSpec()}");
                      },
                      // googleFonts: _myGoogleFonts
                    ),
                  ),
                ));
          },
        );
      },
      child: Container(
          width: widget.width,
          height: widget.height,
          child: Container(
            decoration: BoxDecoration(
                color: darkColor,
                borderRadius: BorderRadius.circular(small)),
            child: Padding(
              padding: EdgeInsets.all(tiny),
              child: Row(
                children: [
                  Text("Font Style:",style: themeData.textTheme.subtitle2,),
                  Text(" ${pickerFont.fontFamily}",style: TextStyle(
                      fontFamily:themeData.textTheme.bodyText1!.fontFamily,
                      color:themeData.textTheme.bodyText1!.color,
                      fontSize:themeData.textTheme.subtitle2!.fontSize),),
                  Expanded(child: Center(),),
                  FittedBox(child: Icon(Icons.edit_rounded))
                ],
              ),
            ),
          )),
    );
  }
}
