import 'package:alacard_template/constants.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmbossedTextField extends StatefulWidget {
  TextInputType keyboardType;
  TextInputAction textInputAction;
  String text;
  String? initialValue;
  ThemeData themeData;
  double height, width;
  int? lines;
  Function validatorFn;
  Function? onChangedFn,onEditingComplete,onSelectField,onFieldSubmitted;
  bool? enabled,isSelected;
  FocusNode? focusNode;

  EmbossedTextField(
      {required this.text,
      required this.height,
      required this.themeData,
      required this.width,
      required this.validatorFn,
      this.textInputAction = TextInputAction.next,
      this.keyboardType = TextInputType.text,
      this.initialValue,
      this.onChangedFn,
      this.onEditingComplete,
      this.lines,
      this.enabled,
      this.onSelectField,
      this.isSelected});

  @override
  _EmbossedTextFieldState createState() => _EmbossedTextFieldState();
}

class _EmbossedTextFieldState extends State<EmbossedTextField> {
  String? labelText, initialValue;
  ThemeData? themeData;
  double? height, width;
  Color? color;
  int? lines;
  Function? validatorFn;
  bool isPassNotVisible = true , isSelected = false;
  TextInputAction? textInputAction;
  TextInputType? keyboardType;
  late TextEditingController controller;

  @override
  void initState() {
    initialValue = widget.initialValue;
    labelText = widget.text;
    themeData = widget.themeData;
    height = widget.height;
    width = widget.width;
    validatorFn = widget.validatorFn;
    textInputAction = widget.textInputAction;
    keyboardType = widget.keyboardType;
    controller = TextEditingController(text: initialValue);
    lines = widget.lines;
    isSelected = widget.isSelected??false;
  }

  updateState() {
    print("hellppp is pass visible = $isPassNotVisible");
    setState(() {
      isPassNotVisible = !isPassNotVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text == "Profile Link") {
      initialValue = Provider.of<Variables>(context).profileLink;
      controller = TextEditingController(text: initialValue);
      print("profile link changed to $initialValue");
    }
    return Container(
      height: height,
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          EmbossBg(height! * 0.8+(lines!=null?0.2*small*lines!:0), width, themeData: themeData! , depth: ((widget.enabled??true)?12:0)),
          Positioned(
            top:( (widget.enabled??true)?(-height! * 0.1):(-height! * 0.05)) + (lines!=null?lines!:0)*0.1*small,
            left: 3*0.1*small,
            child: Container(
              height: height! * 1.5,
              width: width! - 13,
              margin: EdgeInsets.fromLTRB(5*0.1*small, 0, 5*0.1*small, 0),
              child: TextFormField(
                minLines: lines??1,
                maxLines: lines??1,
                onEditingComplete:widget.onEditingComplete!=null? (){
                    widget.onEditingComplete!(controller.value.text);
                }:null,
                controller: controller,
                textInputAction: textInputAction,
                keyboardType: keyboardType,
                style: themeData!.textTheme.headline4,
                decoration: InputDecoration(
                  labelText: " $labelText",
                  labelStyle: themeData!.textTheme.subtitle2,
                  // hintText: "Enter you $labelText",
                  isDense: true,
                  // contentPadding: EdgeInsets.all(0),
                  border: InputBorder.none,
                ),
                validator: validatorFn as String? Function(String?)?,
                obscureText: keyboardType == TextInputType.visiblePassword
                    ? isPassNotVisible
                    : false,
                obscuringCharacter: "⬤",
                onChanged: widget.onChangedFn as String? Function(String?)?,
                enabled: widget.enabled??true,
              ),
            ),
          ),
          keyboardType == TextInputType.visiblePassword
              ? Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: (){
                      updateState();
                    },
                    child: SizedBox(
                      height: height!*0.8,
                      width: height!*0.6,
                      child: Icon(
                          ((isPassNotVisible)
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded)
                      ),
                    ),
                  ),
                )
              : Center(),
          if(widget.onSelectField!=null)
            Positioned(
              right: 0,
              top: 0,
              child: ButtonType2(
                isActivated: isSelected,
                themeData: themeData!,
                subText: "Add \non card    ",
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    isSelected=!isSelected;
                  });
                  widget.onSelectField!(isSelected);
                },
                height: 35*0.1*small,
                width: 30*0.1*small,
                icon: Icons.call_made_rounded,
              ),
            ),
        ],
      ),
    );
  }
}

class SearchField extends StatefulWidget {
  double width;
  Function? onChangedFn;
  SearchField({required this.width, required this.onChangedFn});
  @override
  _SearchFieldState createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late double width;
  @override
  void initState() {
    width = widget.width;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      height: 6*small,
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          EmbossBg(5*small, width,
              themeData: themeData,
              depth: small,),
          Positioned(
            top: -6*0.1*small,
            left: 3*0.1*small,
            child: Container(
              height: 90*0.1*small,
              width: width - large,
              margin: EdgeInsets.fromLTRB(5*0.1*small, 0, 5*0.1*small, 0),
              child: TextFormField(
                textInputAction: TextInputAction.search,
                keyboardType: TextInputType.name,
                style: themeData.textTheme.headline2,
                decoration: InputDecoration(
                  labelText: " Search",
                  labelStyle: themeData.textTheme.subtitle2,
                  isDense: true,
                  border: InputBorder.none,
                ),
                onChanged: widget.onChangedFn as String? Function(String?)?,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

