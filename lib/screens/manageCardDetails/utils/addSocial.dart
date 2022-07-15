import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardFields/contactNo.dart';
import 'package:alacard_template/database/cardFields/socialMedia.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/common/customDropDown.dart';
import 'package:alacard_template/utils/common/textField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddSocial extends StatefulWidget {
  CRUD crud;
  int index;

  AddSocial({required this.crud, this.index = 0});

  @override
  _AddSocialState createState() => _AddSocialState();
}

class _AddSocialState extends State<AddSocial> {
  late CRUD _crud;
  SocialMedia _socialMedia = SocialMedia(username: "", type: "Other");
  final formKey = GlobalKey<FormState>();
  bool isValid = true, isIconVisible = false, isUrlVisible = false;
  late String buttonName;
  String heading = "Choose Platform";
  String? linkValue, username;
  late int _index;
  ButtonType2? socialIconButton;

  @override
  void initState() {
    _index = widget.index;
    _crud = widget.crud;
    switch (_crud) {
      case CRUD.create:
        buttonName = " Add ";
        Provider.of<Variables>(context, listen: false)
            .setProfileLink("");
        break;
      case CRUD.update:
        buttonName = " Save ";
        List<SocialMedia> _list;
        _list = Provider.of<Variables>(context, listen: false)
            .tempCardDetails
            .socialMedias!;
        _socialMedia = _list[_index];
        String _type = _socialMedia.type;
        linkValue = _socialMedia.profileLink;
        if (socialType.contains(_type)) {
          heading = _type;
          isIconVisible = true;
        } else {
          heading = "Other";
        }
        Provider.of<Variables>(context, listen: false).setProfileLink(_socialMedia.profileLink??"");
        break;
      default:
        break;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    try {
      String newValue =
          socialTypeDetails[_socialMedia.type]![0].replaceFirst("_", username);
      print("link value  = $linkValue & current = $newValue");
      if (_socialMedia.type != "Other") {
          linkValue = newValue;
          Provider.of<Variables>(context, listen: false)
              .setProfileLink(linkValue!);
      }
    } catch (e) {}

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
                list: socialType,
                heading: heading,
                onSelectFunction: (selected) {
                  setState(() {
                    isIconVisible = false;
                  });
                  if (selected != "Other") {
                    setState(() {
                      isIconVisible = true;
                      _socialMedia.type = selected;
                    });
                    linkValue = socialTypeDetails[_socialMedia.type]![0]
                        .replaceFirst("_", "");
                    Provider.of<Variables>(context, listen: false)
                        .setProfileLink(linkValue!);
                  } else {
                    Provider.of<Variables>(context, listen: false)
                        .setProfileLink("");
                  }
                },
                otherTextField: EmbossedTextField(
                  text: "Platform Name",
                  initialValue:
                      (_crud == CRUD.update) ? _socialMedia.type : null,
                  themeData: themeData,
                  width: deviceWidth * 0.9,
                  height: 6*small,
                  validatorFn: (value) {
                    if (value != null && value != "") {
                      _socialMedia.type = value;
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (isIconVisible)
                      ? Container(
                          height: large,
                          width: large,
                          padding: EdgeInsets.only(bottom: small,right: tiny),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: large,
                                child: Icon(
                                  _socialMedia.type != "Other"
                                      ? socialTypeDetails[_socialMedia.type]![1]
                                      : Icons.stream,
                                  size: large * 0.5,
                                ),
                              ),
                              Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(horizontal: tiny),
                                  child: FittedBox(
                                    child: Text(
                                      _socialMedia.type,
                                      style: TextStyle(
                                        fontFamily: themeData
                                            .textTheme.bodyText2!.fontFamily,
                                        color:
                                            themeData.textTheme.bodyText2!.color,
                                        fontSize: themeData
                                            .textTheme.bodyText2!.fontSize,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ))
                            ],
                          ),
                        )
                      : Center(),
                  SizedBox(
                    width: (isIconVisible)
                        ? deviceWidth * 0.9 - large
                        : deviceWidth * 0.9,
                    child: EmbossedTextField(
                      text: "Username",
                      initialValue: _socialMedia.username,
                      themeData: themeData,
                      width: deviceWidth * 0.9,
                      height: 6*small,
                      onChangedFn: (value) {
                        setState(() {
                          username = value;
                        });
                      },
                      validatorFn: (value) {
                        if (value == null||value == "") {
                          setState(() {
                            isValid = false;
                          });
                          return "Please Enter Username";
                        } else {
                          setState(() {
                            _socialMedia.username = value;
                            isValid = true;
                          });
                            if (_socialMedia.type != "Other") {
                              // its either custom or in the list
                              if (socialType.contains(_socialMedia.type) &&
                                  linkValue == null) {

                                setState(() {
                                  linkValue =
                                      socialTypeDetails[_socialMedia.type]![0]
                                          .replaceFirst(
                                          "_", _socialMedia.username);
                                });
                                Provider.of<Variables>(context, listen: false)
                                    .setProfileLink(linkValue!);
                              }
                            }
                          return null;
                        }
                      },
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ],
              ),
            ),
            (isValid) ? Center() : Spacing().mediumWidget,
            EmbossedTextField(
              text: "Profile Link",
              themeData: themeData,
              width: deviceWidth * 0.9,
              height: 6*small,
              validatorFn: (value) {
                if (value == null||value == "") {
                  setState(() {
                    isValid = false;
                  });
                  return "Invalid";
                } else {
                  setState(() {
                    _socialMedia.profileLink = value;
                    isValid = true;
                  });
                  return null;
                }
              },
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.url,
            ),
            (isValid) ? Center() : Spacing().mediumWidget,
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
                    height: medium*1.5,
                    onPressed: () {
                      setState(() {
                        isValid = formKey.currentState!.validate();
                      });
                      if (isValid) {
                        Provider.of<Variables>(context, listen: false).editTempCardSocialDetails(
                          socialMedia: _socialMedia,
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
