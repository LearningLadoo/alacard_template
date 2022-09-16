import 'package:alacard_template/constants.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/design/editFont.dart';
import 'package:alacard_template/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerButton extends StatefulWidget {
  Color initialColor;
  double height;
  Function onSelect;
  String? title;
  ColorPickerButton({required this.height,required this.initialColor,required this.onSelect,this.title});
  @override
  _ColorPickerButtonState createState() => _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  late double height;
  Color? color , tempColor;
  @override
  void initState() {
    height = widget.height;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    color = color??widget.initialColor;
    Color darkColor = getAdjustColor(themeData.scaffoldBackgroundColor, -7 * (themeMode == ThemeMode.light ? 2 : 1));

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
                  child: SizedBox(
                    width: deviceWidth*0.9,
                    child: Column(
                      children: [
                        Text("Choose Color",style: themeData.textTheme.headline2,),
                        Spacing().tinyWidget,
                        ColorPicker(
                          pickerColor:color!,
                          onColorChanged: (color){
                            setState(() {
                              tempColor = color;
                            });},
                        ),
                        ButtonType3(
                          height: medium*1.2,
                          width: large*2.2,
                          text: " set color ",
                          offset: 0,
                          themeData: themeData,
                          isbnw: true,
                          bgColor: themeData.colorScheme.onPrimary.withOpacity(0),
                          onPressed: () async {
                            setState(() {
                              color = tempColor;
                              widget.onSelect(color);
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ));
          },
        );
      },
      child: FittedBox(
        child: Container(
          height: height,
          decoration: BoxDecoration(
              color: darkColor,
              borderRadius: BorderRadius.circular(small)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.title==""?0.0:tiny),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(widget.title??"Font Colour",style: themeData.textTheme.subtitle2),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: tiny),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(small*0.7),
                    color:color,
                  ),
                  height: height*0.8,
                  width: height*0.8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
