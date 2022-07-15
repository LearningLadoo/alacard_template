import 'dart:developer';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/database/cardFields/contactNo.dart';
import 'package:alacard_template/database/cardFields/customField.dart';
import 'package:alacard_template/database/cardFields/socialMedia.dart';
import 'package:alacard_template/database/databaseHelper.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/main.dart';
import 'package:alacard_template/providers/cardsMapProvider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/screens/manageCardDetails/utils/addCustom.dart';
import 'package:alacard_template/screens/manageCardDetails/utils/addSocial.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import 'common/buttons.dart';
import '../screens/manageCardDetails/utils/addContacts.dart';

final String _TAG = "Widgets/widgets";

Widget Loader(double size) {
  return Container(
    height: size,
    width: size,
    child: Lottie.asset("$lottieDir/loader.json"),
  );
}

ProgressHUD OnScreenLoader(
    {required Widget child, required ThemeData themeData , Color? barrierColor}) {
  return ProgressHUD(
    indicatorWidget: Loader(10*small),
    backgroundColor: themeData.scaffoldBackgroundColor,
    borderColor: themeData.scaffoldBackgroundColor,
    textStyle: themeData.textTheme.bodyText1!,
    barrierColor: barrierColor??themeData.colorScheme.secondary.withOpacity(0.3),
    child: child,
  );
}

ProgressHUD OnWidgetLoader(
    {required Widget child, required ThemeData themeData}) {
  return ProgressHUD(
    indicatorWidget: Loader(5*small),
    backgroundColor: themeData.scaffoldBackgroundColor.withOpacity(0.5),
    borderColor: themeData.scaffoldBackgroundColor.withOpacity(0.5),
    textStyle: themeData.textTheme.bodyText1!,
    barrierColor: themeData.scaffoldBackgroundColor.withOpacity(0.5),
    child: child,
  );
}

AppBar AlacardAppBar(BuildContext context,{bool displayBack = false,bool displayMenu = false,List<Widget>? actions,Widget? title , String? screen , bool askBeforeExiting = false ,bool takeToDashboard = false, bool restartApp = false, bool displayToggle = false}) {
  Widget? tempLeftButton;
  bool minimal = Provider.of<Variables>(context , listen: true).isMinimal;
  ThemeData themeData = Theme.of(context);
  late double toolBarHeight ;
  if (displayBack) {
    tempLeftButton = ButtonType2(
      themeData: Theme.of(context),
      subText: " Go Back",
      onPressed: () {
        // if (takeToDashboard)
        //   Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (BuildContext context) => Dashboard(),
        //       ));
        /// restartApp deletes all the previous routes
        if(restartApp)Navigator.pushAndRemoveUntil(context??bc_currContext??context,MaterialPageRoute(builder: (BuildContext context) => MainApp()),(Route<dynamic> route) => false);
        // askBeforeExiting shows an exit dialog
        else if(askBeforeExiting && !restartApp)AlacardDialog(context, child: ExitDialog(context),barrierOpacity: 0.5);
        // pop
        else Navigator.pop(context);
      },
      height: large,
      width: large,
      icon: Icons.arrow_back_rounded,
    );
  }

  if (displayMenu) {
    tempLeftButton = ButtonType2(
      themeData: Theme.of(context),
      subText: "Menu",
      onPressed: () {
        // Navigator.pushNamed(context, r_menu);
       },
      height: large,
      width: large,
      icon: (Icons.menu_rounded),
    );
  }
  switch(screen.toString()){
    case r_manageCards:
      toolBarHeight = (!minimal) ? large : large - 4;
      break;
    // case r_dashboard:
    //   toolBarHeight = (!minimal) ? large : large - small;
    //   break;
    // case r_menu:
    //   toolBarHeight = (!minimal) ? large : large - small;
    //   break;
    default:
      toolBarHeight = (!minimal) ? large : large;
  }
  return AppBar(
    bottom: displayToggle?TabBar(
      padding: EdgeInsets.zero,
      tabs: [
        Tab(text: "Received",iconMargin: EdgeInsets.all(0),),
        Tab(text: "Uploaded",iconMargin: EdgeInsets.all(0),),
      ],
      indicatorColor: themeData.colorScheme.onPrimary.withOpacity(0.6),
      indicatorWeight: tiny/2,
      labelStyle: themeData.textTheme.subtitle1,
      labelColor:  themeData.colorScheme.onPrimary.withOpacity(0.9),
      unselectedLabelStyle: themeData.textTheme.subtitle1,
      unselectedLabelColor:  themeData.iconTheme.color!.withOpacity(0.7),
    ):null,
    title: title,
    centerTitle: true,
    toolbarHeight: toolBarHeight,
    elevation: 0.0,
    titleSpacing: 0,
    leadingWidth: large,
    leading: tempLeftButton ?? Center(),
    actions: actions ?? <Widget>[],
  );
}
Widget OrDivider(ThemeData themeData) {
  return Row(
    children: [
      Expanded(child: Divider()),
      Text(
        "  OR  ",
        style: themeData.textTheme.headline6,
      ),
      Expanded(child: Divider()),
    ],
  );
}

Widget EmbossBg(double height, double? width,
    {required ThemeData themeData,
    int dark = 0,
    Widget? child,
    double depth = 12}) {
  double offset = depth;
  Color color = (themeData.shadowColor);
  Color darkColor = getAdjustColor(color, -offset - dark);
  Color lightColor = getAdjustColor(color, offset);
  List<BoxShadow> shadowList = [
    BoxShadow(
      color: lightColor,
      offset: Offset(offset / 4, offset / 4),
      blurRadius: offset / 8,
    ),
    BoxShadow(
      color: darkColor,
      offset: Offset(0 - offset / 6, 0 - offset / 6),
      blurRadius: offset / 8,
    ),
  ];
  return Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        gradient: LinearGradient(
          begin: Alignment.lerp(Alignment.centerLeft, Alignment.topLeft, 0.5)!,
          end: Alignment.lerp(
              Alignment.centerRight, Alignment.bottomRight, 0.5)!,
          colors: [getAdjustColor(color, -10), getAdjustColor(color, -5)],
        ),
        boxShadow: shadowList),
    child: child ?? Center(),
  );
}

Widget ElevatedBg(double height, double width, ThemeData themeData,
    {int dark = 0, double? offset, Widget? child , bool isLightBg = false}) {
  offset = offset ?? 7;
  Color color = themeData.scaffoldBackgroundColor;
  Color darkColor =
      getAdjustColor(color, -offset * (themeMode == ThemeMode.light ? 2 : 1));
  Color lightColor = getAdjustColor(color, offset);
  List<BoxShadow> shadowList = [
    BoxShadow(
      color: darkColor,
      offset: Offset(offset, offset),
      blurRadius: offset,
    ),
    BoxShadow(
      color: lightColor.withOpacity(0.8),
      offset: Offset(
        -offset,
        -offset,
      ),
      blurRadius: offset,
    ),
  ];
  LinearGradient gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [isLightBg? themeData.iconTheme.color!.withOpacity(1.0):color, isLightBg? themeData.iconTheme.color!.withOpacity(1.0):color],
  );
  return Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        gradient: gradient,
        boxShadow: shadowList),
    child: child ?? Center(),
  );
}

/// dialogs
Widget ExitDialog(BuildContext context) {
  ThemeData themeData = Theme.of(context);

  return Container(
    height: 3 * large,
    width: deviceWidth - large,
    decoration: BoxDecoration(
      color: themeData.backgroundColor,
      borderRadius: BorderRadius.circular(small),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          "Your data might not be saved.\nDo you still want to leave?",
          style: themeData.textTheme.headline4,
        ),
        Spacing().smallWiget,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ButtonType3(
              height: medium*1.2,
              width: large*2.2,
              text: " Yes ",
              offset: 0,
              themeData: themeData,
              isbnw: true,
              bgColor: themeData.colorScheme.onPrimary.withOpacity(0),
              onPressed: () async {
                Navigator.pop(context);
                Navigator.pop(bc_alacardDialogContext);
              },
            ),
            ButtonType3(
              height: medium*1.2,
              width: large*2.2,
              text: " Cancel ",
              offset: 0,
              themeData: themeData,
              isbnw: true,
              bgColor: themeData.colorScheme.onPrimary,
              onPressed: () async {
                Navigator.pop(bc_alacardDialogContext);
              },
            ),
          ],
        ),
      ],
    ),
  );
}

Widget ContactCard(BuildContext context, List<ContactNo> contactList, int index, ThemeData themeData , {CRUD crud = CRUD.update}) {
  ContactNo contactNo = contactList[index];
  bool minimal = Provider.of<Variables>(context, listen: false).isMinimal;
  return Container(
    padding: EdgeInsets.symmetric(horizontal: small),
    height: contactCardHeight,
    width: deviceWidth * 0.9,
    child: InkWell(
      onTap: () {
        if(crud == CRUD.read){
          dynamicUrlOps(data: "${contactNo.countryCode}${contactNo.number}" , urlOp: UrlOp.phone);
        }else {
          openBottomSheet(context, AddContacts(crud: CRUD.update, index: index));
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contactNo.type,
            style: TextStyle(
                fontFamily: themeData.textTheme.subtitle2!.fontFamily,
                color:themeData.textTheme.subtitle2!.color ,
                fontSize: themeData.textTheme.bodyText2!.fontSize!),
          ),
          Row(
            children: [
              Expanded(
                child: Text("${contactNo.countryCode} ${contactNo.number}",
                    style: themeData.textTheme.headline4,
                  maxLines: 1,
                  softWrap: false,
                  // overflow: TextOverflow.ellipsis,
                ),
              ),
              // todo add verified
              // (!minimal)
              //     ? Text(
              //         contactNo.isVerified ? "verified " : "unverified ",
              //         style: TextStyle(
              //             fontFamily: themeData.textTheme.bodyText2!.fontFamily,
              //             color: contactNo.isVerified
              //                 ? themeData.focusColor
              //                 : themeData.errorColor,
              //             fontSize: themeData.textTheme.headline2!.fontSize!/20*10),
              //       )
              //     : Center(),
              // CircleAvatar(
              //   radius: tiny,
              //   backgroundColor: contactNo.isVerified
              //       ? themeData.focusColor
              //       : themeData.errorColor,
              // ),
              if(crud != CRUD.read)
              ButtonType2(
                  subText: "",
                  themeData: themeData,
                  width: 1.5*small,
                  height: 4*small,
                  onPressed: () {
                    Provider.of<Variables>(context, listen: false)
                        .editTempCardContactDetails(
                            contactNo: contactNo,
                            crud: CRUD.delete,
                            index: index);
                  },
                  icon: Icons.delete_rounded)
            ],
          ),
        ],
      ),
    ),
  );
}

Widget SocialCard(BuildContext context, List<SocialMedia> socialList, int index,ThemeData themeData , {CRUD crud = CRUD.update}) {
  SocialMedia socialMedia = socialList[index];
  bool minimal = Provider.of<Variables>(context, listen: false).isMinimal;
  return Container(
    padding: EdgeInsets.symmetric(horizontal: small),
    height: contactCardHeight,
    width: deviceWidth * 0.9,
    child: InkWell(
      onTap: () {
        if(crud == CRUD.read){
          dynamicUrlOps(data: "${socialMedia.profileLink}", urlOp: UrlOp.link);
        }else {
          openBottomSheet(context, AddSocial(crud: CRUD.update, index: index));
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            socialMedia.type,
            style: TextStyle(
                fontFamily: themeData.textTheme.subtitle2!.fontFamily,
                color:themeData.textTheme.subtitle2!.color ,
                fontSize: themeData.textTheme.bodyText2!.fontSize!),
          ),
          Row(
            children: [
              (socialTypeDetails.containsKey(socialMedia.type))
                  ? Padding(
                      padding: EdgeInsets.only(right: small),
                      child: Icon(
                        socialTypeDetails[socialMedia.type]![1],
                        size: medium,
                      ),
                    )
                  : Center(),
              Expanded(
                  child: Text(socialMedia.username,
                      style: themeData.textTheme.headline4,
                    softWrap: false,
                    maxLines: 1,
                  )),

              //todo add verified
              // (!minimal)
              //     ? Text(
              //         socialMedia.isVerified ? "verified " : "unverified ",
              //         style: TextStyle(
              //             fontFamily: themeData.textTheme.bodyText2!.fontFamily,
              //             color: socialMedia.isVerified
              //                 ? themeData.focusColor
              //                 : themeData.errorColor,
              //             fontSize: themeData.textTheme.headline2!.fontSize!/20*10),
              //       )
              //     : Center(),
              // CircleAvatar(
              //   radius: tiny,
              //   backgroundColor: socialMedia.isVerified
              //       ? themeData.focusColor
              //       : themeData.errorColor,
              // ),
              if(crud != CRUD.read)
              ButtonType2(
                  subText: "",
                  themeData: themeData,
                  width: 1.5*small,
                  height: 4*small,
                  onPressed: () {
                    Provider.of<Variables>(context, listen: false)
                        .editTempCardSocialDetails(
                            socialMedia: socialMedia,
                            crud: CRUD.delete,
                            index: index);
                  },
                  icon: Icons.delete_rounded)
            ],
          ),
        ],
      ),
    ),
  );
}

Widget CustomFieldCard(BuildContext context, List<CustomField> customFieldList,
    int index, ThemeData themeData  , {CRUD crud = CRUD.update}) {
  CustomField customField = customFieldList[index];
  late String data;
  switch (customField.infoType) {
    case "Address":
      data = customField.fieldData.address;
      break;
    default:
      data = customField.fieldData;
  }
 return Container(
    padding: EdgeInsets.symmetric(horizontal: small),
    height: contactCardHeight,
    width: deviceWidth * 0.9,
    child: InkWell(
      onTap: () {
        if(crud == CRUD.read){
          switch (customField.infoType) {
            case "Link":
              {
                dynamicUrlOps(data: data,urlOp: UrlOp.link);
                break;
              }
            case "Email":
              {
                dynamicUrlOps(data: data,urlOp: UrlOp.email);
                break;
              }
            case "Address":
              {
                // todo handle address type
                break;
              }
            default:{}
          }
        }else {
          openBottomSheet(context, AddCustom(crud: CRUD.update, index: index));
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customField.heading,
            style: TextStyle(
                fontFamily: themeData.textTheme.subtitle2!.fontFamily,
                color:themeData.textTheme.subtitle2!.color ,
                fontSize: themeData.textTheme.bodyText2!.fontSize!),
          ),
          Row(
            children: [
              Expanded(
                  child: Text(
                      "$data",
                      style: themeData.textTheme.headline4,
                      softWrap: false,
                      maxLines: 1,
                  )),
              if(crud != CRUD.read)
              ButtonType2(
                  subText: "",
                  themeData: themeData,
                  width: 1.5*small,
                  height: 4*small,
                  onPressed: () {
                    Provider.of<Variables>(context, listen: false)
                        .editTempCardCustomFields(
                            customField: customField,
                            crud: CRUD.delete,
                            index: index);
                  },
                  icon: Icons.delete_rounded)
            ],
          ),
        ],
      ),
    ),
  );
}

Widget UnfocusKeyboardOnTap(BuildContext context,{required Widget child}){
  return InkWell(
    onTap: (){
      FocusScope.of(context).unfocus();
    },
    splashColor: Colors.transparent,
    focusColor: Colors.transparent,
    highlightColor: Colors.transparent,
    child: child,
  );
}