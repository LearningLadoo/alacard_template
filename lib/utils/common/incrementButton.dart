import 'package:alacard_template/constants.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/widgets.dart';
import 'package:flutter/material.dart';

class IncrementButton extends StatefulWidget {
  double height, width , max , min , value , factor; // width is for written text
  String? tag;
  bool isDouble;
  Function onEdit;
  IncrementButton(
      {required this.height,
      required this.width,
      required this.value,
      required this.max,
      required this.min,
      required this.factor,
      this.tag,
      required this.onEdit,
      this.isDouble = true
      });
  @override
  _IncrementButtonState createState() => _IncrementButtonState();
}

class _IncrementButtonState extends State<IncrementButton> {
  late double height,width,max,min,value;
  late TextEditingController controller;
  @override
  void initState() {
    height = widget.height;
    width = widget.width;
    max = widget.max;
    min = widget.min;
    value = widget.value;
    controller = TextEditingController(text: displayValue(limitValue(value)));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    Color color = themeData.scaffoldBackgroundColor;
    Color darkColor = getAdjustColor(color, -7 * (themeMode == ThemeMode.light ? 2 : 1));
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
          color: darkColor,
          borderRadius: BorderRadius.circular(small)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          widget.tag==""?Center():
          Text(" "+(widget.tag??"Size"), style: themeData.textTheme.subtitle2),
          Container(
            height: height-small,
            width: height*3,
            margin: EdgeInsets.symmetric(horizontal: tiny),
            decoration: BoxDecoration(
                color: color.withOpacity(0.7),
                borderRadius: BorderRadius.circular(small)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // - minus
                ButtonType2(
                    themeData: themeData,
                    subText: "",
                    onPressed: () {
                      widget.onEdit(updateValue(widget.factor*-1));
                    },
                    height: height*0.95,
                    width: height*0.8,
                    icon: Icons.remove_rounded),
                // value
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration.collapsed(hintText: ""),
                    textAlign: TextAlign.center,
                    controller: controller,
                    style: themeData.textTheme.headline4,
                    onEditingComplete: (){
                      double temp = limitValue(double.parse(controller.value.text));
                      widget.onEdit(temp*1.0);
                      // FocusScope.of(context).unfocus();
                      setState(() {
                        value = temp;
                        controller = TextEditingController(text: displayValue(value));
                      });
                    },
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                // + add
                ButtonType2(
                    themeData: themeData,
                    subText: "",
                    onPressed: () {
                      widget.onEdit(updateValue(widget.factor));
                    },
                    height: height*0.95,
                    width: height*0.8,
                    icon: Icons.add_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
  String displayValue(double yo){
    if(widget.isDouble){
      return yo.toString();
    }
    return yo.toInt().toString();
  }
  double limitValue(double temp){
    if(temp>max)temp = max;
    if(temp<min)temp = min;
    return temp*1.0;
  }
  double updateValue(double x){
    double temp = limitValue(value + x);
    setState(() {
     value = temp;
     controller = TextEditingController(text: displayValue(value));
    });
    return temp*1.0;
  }
}
