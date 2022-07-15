import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardFields/contactNo.dart';
import 'package:alacard_template/database/cardFields/customField.dart';
import 'package:alacard_template/database/cardFields/socialMedia.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/common/customDropDown.dart';
import 'package:alacard_template/utils/common/textField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddCustom extends StatefulWidget {
  CRUD crud;
  int index;

  AddCustom({required this.crud, this.index = 0});

  @override
  _AddCustomState createState() => _AddCustomState();
}

class _AddCustomState extends State<AddCustom> {
  late CRUD _crud;
  CustomField _customField = CustomField(heading: "");
  final formKey = GlobalKey<FormState>();
  bool isValid = true;
  late String buttonName , _type ;
  String heading = "Type";
  late int _index;
  TextInputType _textInputType = TextInputType.text;

  @override
  void initState() {
    _index = widget.index;
    _crud = widget.crud;
    switch (_crud) {
      case CRUD.create: buttonName = " Add ";
        Provider.of<Variables>(context, listen: false).setProfileLink("");
        break;
      case CRUD.update: buttonName = " Save ";
        List<CustomField> _list;
        _list = Provider.of<Variables>(context, listen: false)
            .tempCardDetails
            .customFields!;
        _customField = _list[_index];
        _type = _customField.infoType;
        heading = _type;
        _textInputType = getTextInputType(_type);
        break;
      default:
        break;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      margin: EdgeInsets.fromLTRB(small, small, small, small),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: deviceWidth,
              child: CustomDropDown(
                forceEnableTextField: true,
                list: infoType,
                heading: heading,
                onSelectFunction: (selected) {
                  setState(() {
                    _type = selected;
                    _customField.infoType = _type;
                    _textInputType = getTextInputType(_type);
                  });
                },
                otherTextField:EmbossedTextField(
                  text: "Heading",
                  initialValue: _customField.heading,
                  themeData: themeData,
                  width: deviceWidth * 0.9,
                  height: 6*small,
                  validatorFn: (value) {
                    if (value == null||value == "") {
                      return "Please give heading";
                    } else {
                      _customField.heading = value;
                      return null;
                    }
                  },
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                ),
              ),
            ),
            (isValid) ? Center() : Spacing().mediumWidget,
            Container(
              margin: EdgeInsets.only(top:small),
              child: EmbossedTextField(
                initialValue: _customField.fieldData,
                text: "Data",
                themeData: themeData,
                width: deviceWidth * 0.87,
                height: 6*small,
                validatorFn: (value) {
                  if (value == null||value == "") {
                    return "Please Enter Valid Input";
                  } else {
                      _customField.fieldData = value;
                    return null;
                  }
                },
                textInputAction: TextInputAction.done,
                keyboardType: _textInputType,
              ),
            ),
            (isValid) ? Center() : Spacing().mediumWidget,
            Container(
              margin: EdgeInsets.only(right: small,top: tiny),
              alignment: Alignment.centerRight,
              child: ButtonType3(
                width: 6*small,
                height: medium*1.5,
                onPressed: () {
                  setState(() {
                    isValid = formKey.currentState!.validate();
                  });
                  if (isValid) {
                    Provider.of<Variables>(context, listen: false).editTempCardCustomFields(
                        customField: _customField,
                        crud: _crud,
                        index: _index);
                    _customField.printAllData();
                    Navigator.pop(context);
                  }
                },
                themeData: themeData,
                text: buttonName,
                bgColor: themeData.colorScheme.onPrimary,
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
      ),
    );
  }

  TextInputType getTextInputType(String type){
    switch(type){
      case "Link":return TextInputType.url;
      case "Email": return TextInputType.emailAddress;
      default : return TextInputType.text;
    }
  }
}
