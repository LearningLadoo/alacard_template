import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardFields/contactNo.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/common/customDropDown.dart';
import 'package:alacard_template/utils/common/textField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddContacts extends StatefulWidget {
  CRUD crud;
  int index;

  AddContacts({required this.crud, this.index = 0});

  @override
  _AddContactsState createState() => _AddContactsState();
}

class _AddContactsState extends State<AddContacts> {
  late CRUD _crud;
  ContactNo _contactNo = ContactNo(number: "");
  final formKey = GlobalKey<FormState>();
  bool isValid = true;
  late String buttonName;
  String heading =  "Choose Type";
  late int _index;

  @override
  void initState() {
    _index = widget.index;
    _crud = widget.crud;
    switch (_crud) {
      case CRUD.create:
        buttonName = " Add ";
        break;
      case CRUD.update:
        buttonName = " Save ";
        List<ContactNo> _list;
        _list = Provider.of<Variables>(context,listen: false).tempCardDetails.contactNos!;
        _contactNo = _list[_index];
        String _type = _contactNo.type;
        if(contactType.contains(_type)){
          heading = _type;
        }else{
          heading = "Other";
        }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: deviceWidth,
              child: CustomDropDown(
                list: contactType,
                heading:heading,
                onSelectFunction: (selected){
                  setState(() {
                    if(selected!="Other"){
                      _contactNo.type = selected;
                    }
                  });
                },
                otherTextField: EmbossedTextField(
                  text: "Type",
                  initialValue: (_crud==CRUD.update)?_contactNo.type:null,
                  themeData: themeData,
                  width: deviceWidth * 0.9,
                  height: 6*small,
                  validatorFn: (value) {
                    if(value!=null){
                      _contactNo.type = value;
                    }
                  },
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: small + tiny),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  EmbossedTextField(
                    initialValue: _contactNo.countryCode,
                    text: "Code",
                    themeData: themeData,
                    width: large,
                    height: 6*small,
                    validatorFn: (value) {
                      if (value.startsWith("+")) {
                        if (value.length > 1) {
                          _contactNo.countryCode = value;
                          return null;
                        } else {
                          return "invalid";
                        }
                      } else {
                        return "add '+'";
                      }
                    },
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                  ),
                  EmbossedTextField(
                    text: "Contact Number",
                    initialValue: _contactNo.number,
                    themeData: themeData,
                    width: deviceWidth - 2 * large,
                    height: 6*small,
                    validatorFn: (value) {
                      if (value == null || value.length < 5) {
                        return "Please Enter valid number";
                      } else {
                        _contactNo.number = value;
                        return null;
                      }
                    },
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: small),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ButtonType3(
                  //   width: 70,
                  //   height: 40,
                  //   onPressed: () {
                  //     //todo : verify number with some means
                  //   },
                  //   themeData: themeData,
                  //   text: " Verify ",
                  //   bgColor: themeData.iconTheme.color,
                  //   isbnw: true,
                  // ),
                  ButtonType3(
                    width: 6*small,
                    height: 1.5*medium,
                    onPressed: () {
                      setState(() {
                        isValid = formKey.currentState!.validate();
                      });
                      if (isValid) {
                        Provider.of<Variables>(context,listen: false)
                            .editTempCardContactDetails(
                            contactNo: _contactNo,
                            crud: _crud,
                            index: _index);
                        Navigator.pop(context);
                      }
                    },
                    themeData: themeData,
                    text: buttonName,
                    bgColor: themeData.colorScheme.onPrimary,
                    isbnw: true,
                  ),
                ],
              ),
            ),
            (isValid) ? Center() : Spacing().mediumWidget,
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
}
