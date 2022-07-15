import 'package:alacard_template/constants.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
List<String> months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];
class DateTimePicker extends StatefulWidget {
  double height, width;
  String? tag;
  DateTime givenDate;
  Function onConfirm;
  DateTimePicker(
      {required this.height,
        required this.width,
        required this.givenDate,
        this.tag,
        required this.onConfirm,
      });
  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late double height,width;
  late DateTime givenDate;
  late TextEditingController controller;
  DateTime selectedDateTime = DateTime.now();
  late String datePart, timePart;
  @override
  void initState() {
    height = widget.height;
    width = widget.width;
    givenDate = widget.givenDate;
    updateValues(givenDate);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    Color color = themeData.scaffoldBackgroundColor;
    Color darkColor = getAdjustColor(color, -7 * (themeMode == ThemeMode.light ? 2 : 1));

    return GestureDetector(
      onTap: (){
        DatePicker.showDateTimePicker(context,
            showTitleActions: true,
            minTime: DateTime.now(),
            maxTime: DateTime.now().add(Duration(days: 365)),
            onChanged: (date) {
              print('change $date');},
            onConfirm: (date) {
              print('confirm $date');
              widget.onConfirm(date);
              setState(() {
                selectedDateTime = date;
                updateValues(selectedDateTime);
              });
            },
            currentTime: DateTime.now(),
            locale: LocaleType.en,
            theme: DatePickerTheme(
              backgroundColor: themeData.backgroundColor,
              itemStyle: themeData.textTheme.headline4!,
              cancelStyle: TextStyle(
                fontFamily: themeData.textTheme.subtitle2!.fontFamily,
                fontSize: themeData.textTheme.subtitle2!.fontSize,
                color: themeData.textTheme.subtitle1!.color,
              ),
              doneStyle: themeData.textTheme.subtitle2!
            )
        );
      },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: tiny),
          height: widget.height,
          decoration: BoxDecoration(
              color: darkColor,
              borderRadius: BorderRadius.circular(small)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(widget.tag??"",style: themeData.textTheme.subtitle2,),
              Container(
                alignment: Alignment.center,
                height: widget.height-small,
                  padding: EdgeInsets.symmetric(horizontal: tiny),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(small)),
                  child: Text(datePart,style: themeData.textTheme.subtitle1,)),
              Text(" by ",style: themeData.textTheme.subtitle2,),
              Container(
                  alignment: Alignment.center,
                  height: widget.height-small,
                  padding: EdgeInsets.symmetric(horizontal: tiny),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(small)),
                  child: Text(timePart,style: themeData.textTheme.subtitle1,)
              ),
            ],
          ),
        ),
    );
  }
  void updateValues(DateTime dt){
    setState(() {
      datePart = "${dt.day} ${months[dt.month-1]},${dt.year%100}";
      timePart = "${dt.hour<10?"0${dt.hour}":dt.hour}:${dt.minute<10?"0${dt.minute}":dt.minute}";
    });
  }
}
