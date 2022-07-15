import 'dart:developer';
import 'dart:io';
import 'package:alacard_template/constants.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDropDown extends StatefulWidget {
  List<String> list;
  Function? onSelectFunction;
  String heading;
  Widget? otherTextField;
  bool forceEnableTextField;

  CustomDropDown(
      {required this.list, required this.heading, this.otherTextField , this.onSelectFunction , this.forceEnableTextField = false});

  @override
  _CustomDropDownState createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  bool _isBackPressedOrTouchedOutSide = false,
      _isDropDownOpened = false,
      _isPanDown = false;

  late List<String> _list;
  late String _selectedItem;

  Widget? otherTextField;

  @override
  void initState() {
    _list = widget.list;
    _selectedItem = widget.heading;
    otherTextField = widget.otherTextField;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: small),
          // alignment: Alignment.bottomCenter,
          height: 5*small,
          width: (_selectedItem == "Other"|| widget.forceEnableTextField)
              ? deviceWidth * 0.4
              : deviceWidth - 2 * small,
          child: InkWell(
                onTap: (){
                  openBottomSheet(context,dd(widget.list,onSelectedFn));
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: small*1.3),
                  padding: EdgeInsets.fromLTRB(medium,0,small,0),
                  decoration: BoxDecoration(
                    color: getAdjustColor(themeData.shadowColor, -10),
                    borderRadius: BorderRadius.circular(small),
                  ),
                  child: Row(
                    children: [
                      Text(_selectedItem,style: themeData.textTheme.headline4!,),
                      Expanded(child: Center()),
                      Icon(Icons.arrow_drop_down_rounded,size: large*0.8,),
                    ],
                  ),
                ),
              )
        ),
        Visibility(
            visible: (_selectedItem == "Other"|| widget.forceEnableTextField),
            child: Container(
                margin: EdgeInsets.only(top: small * 1.2),
                height: 5*small,
                width: (_selectedItem == "Other"|| widget.forceEnableTextField)
                    ? deviceWidth * 0.5
                    : 0,
                child: otherTextField ?? Center()))
      ],
    );
  }
  void onSelectedFn(String selectedItem){
    log(selectedItem);
    setState(() {
      _selectedItem = selectedItem;
      widget.onSelectFunction!(selectedItem);
    });
  }
}
class dd extends StatelessWidget {
  List list;
  Function OnSelected;
  dd(this.list,this.OnSelected);

  @override
  Widget build(BuildContext context) {
    String? selected;
    return Container(
      height: 5*large,
      padding: EdgeInsets.fromLTRB(small*2, small, small*2, small),
      child: Column(
        children: [
          SizedBox(
            height: large*3.5,
            child: CupertinoPicker(
              children: list.map((e) => Text(e)).toList(),
              onSelectedItemChanged: (selectedItem) {
                selected = list[selectedItem];
                log("selected is $selected");
            },
              itemExtent: medium*1.5,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ButtonType3(
              width: 6*small,
              height: 1.5*medium,
              onPressed: () {
                OnSelected(selected??list[0]);
                Navigator.pop(context);
              },
              themeData: Theme.of(context),
              text: "Done",
              bgColor: Theme.of(context).colorScheme.onPrimary,
              isbnw: true,
            ),
          ),
        ],
      ),
    );
  }
}
