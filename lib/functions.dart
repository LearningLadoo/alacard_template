import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as UI;
import 'dart:ui';
import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardFields/address.dart';
import 'package:alacard_template/database/cardFields/contactNo.dart';
import 'package:alacard_template/database/cardFields/customField.dart';
import 'package:alacard_template/database/cardFields/socialMedia.dart';
import 'package:alacard_template/database/localFunctions.dart';
import 'package:alacard_template/database/sharedPrefsOfUser.dart';
import 'package:alacard_template/providers/templateData.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database/cardData.dart';

final String _TAG = "Functions";
//dimensions
Size screenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

double screenHeight(BuildContext context, {double dividedBy = 1}) {
  return screenSize(context).height / dividedBy;
}

double screenWidth(BuildContext context, {double dividedBy = 1}) {
  return screenSize(context).width / dividedBy;
}

double statusBarHeight(BuildContext context) {
  return MediaQuery.of(context).padding.top;
}
List<String> getSeparatedKeys(String keyy) {
  //business code = TEMPID  ; 6 values
  //employee code = ABCD    ; 4 values
  //input = TAEBMCPDID
  List<String> key = keyy.split("");
  //log("the string is ${key.toString()}");
  return [
    "${key[0]}${key[2]}${key[4]}${key[6]}${key[8]}${key[9]}", //business
    "${key[1]}${key[3]}${key[5]}${key[7]}" //employee
  ];
}
String getProcessedKeys(String bCode , String eCode) {
  return bCode[0]+eCode[0]+bCode[1]+eCode[1]+bCode[2]+eCode[2]+bCode[3]+eCode[3]+bCode[4]+bCode[5];
}

// List<String> getSeparatedID(String UIDwithNumber){
//   if(!UIDwithNumber.contains("-")){
//     logger.e("uid with number is $UIDwithNumber");
//     return [UIDwithNumber];
//   }
//   List<String> temp = UIDwithNumber.split("-");
//   String uid = processStringWrtId(temp[2],temp[1],type: -1)+processStringWrtId(temp[0],temp[1],type: -1);
//   return [uid,temp[1]];
// }
String getNumberFromName(String name){
  String numbers = "0123456789";
  String temp = "";
  for(String i in  name.split("")){
    if(numbers.contains(i)){
      temp=temp+i;
    }
  }
  return temp;
}
// String getProcessedID(String uid,String cardName){
//   logger.wtf("ioi $uid $cardName");
//   if(uid.contains("-")){
//     return uid;
//   }
//   // divide uid in 2 parts, first(x length) and last(x or x+1 length)
//   int dividerIndex = uid.length~/2;
//   String first = uid.substring(0,dividerIndex);
//   String last = uid.substring(dividerIndex);
//   // last+cardNumber+first
//   return processStringWrtId(last,cardName)+"-"+cardName+"-"+processStringWrtId(first,cardName);
// }
// String getProcessedToken(String? token){
//   if(token==null||token=="null"){return "null";}
//   if(token=="${unfinished}null"){return token;}
//   //5c4c15a6-fe49-4271-a730-cf6a18cbc681
//   //48-57 and 97-102 | - = 45
//   //just +1 and reverse
//   // first remove the unfinished tag
//   bool needsUpdate = false;
//   if(token.startsWith(unfinished)){
//     needsUpdate = true;
//     token = token.substring(1);
//   }
//   List<String> temp =  [];
//   for (int i = 0; i < token.length; i++) {
//     if (token.codeUnitAt(i) != 45) {
//       int charCode;
//       if (token.codeUnitAt(i) == 102) {
//         charCode = 48;
//       } else if (token.codeUnitAt(i) == 57) {
//         charCode = 97;
//       } else {
//         charCode = token.codeUnitAt(i) + 1;
//       }
//       temp.add(String.fromCharCode(charCode));
//     } else {
//       temp.add(String.fromCharCode(45));
//     }
//   }
//   //reverse and convert list to String
//   String tem= needsUpdate?unfinished:""+temp.reversed.join();
//   logger.wtf("processedToken khargosh-$tem");
//   return tem;
// }
// String getRealToken(String? token){
//   if(token==null||token=="null"||token==""){return "null";}
//   if(token=="${unfinished}null"){return token;}
//   //just -1 and reverse
//   // first remove the unfinished tag
//   bool needsUpdate = false;
//   if(token.startsWith(unfinished)){
//     needsUpdate = true;
//     token = token.substring(1);
//   }
//   List<String> temp = [];
//   for (int i = 0; i < token.length; i++) {
//     if (token.codeUnitAt(i) != 45) {
//       int charCode;
//       if (token.codeUnitAt(i) == 48) {
//         charCode = 102;
//       } else if (token.codeUnitAt(i) == 97) {
//         charCode = 57;
//       } else {
//         charCode = token.codeUnitAt(i) - 1;
//       }
//       temp.add(String.fromCharCode(charCode));
//     } else {
//       temp.add(String.fromCharCode(45));
//     }
//   }
//   //reverse and convert list to String
//   String tem = needsUpdate?unfinished:""+temp.reversed.join();
//   logger.wtf("realToken khargosh-$tem");
//   return tem;
//
// }
// String processStringWrtId(String string,String cardName , {int type = 1}){
//   List<String> characters = ['0','1','2','3','4','5','6','7','8','9','A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'];
//   //getting number
//   int number = int.parse(getNumberFromName(cardName));
//   //converting to ascii
//   //48-57(10) and 97-102(26) and 65-90(26)
//   List<String> tempList =[];
//   for(int i = 0 ; i< string.length ;i++){
//     int incrementValue = ((i<_processString.length)?_processString[i]:_processString.last)*number;
//     incrementValue = incrementValue.remainder(10+26+26); // filtering to only one loop
//     int index = characters.indexOf(string.substring(i,i+1));
//     int newValue = index+incrementValue*type;
//     index = ((newValue>(10+26+26-1)||newValue<0)?(-(10+26+26)*type+newValue):newValue);
//     tempList.add(characters[index]);
//   }
//   return tempList.join();
// }


ImageProvider handleGetLocalImage(File f, {String? defaultAssetPath}) {
  if (f.existsSync()) {
    return FileImage(f);
  } else {
    return AssetImage(defaultAssetPath!);
  }
}
String getCardImagePath({CardFace? cardFace, String? cardName, bool isMine = false,bool getLatestCard = false}) {
  //if cardName is null then Temp
  //if mine is false the Cards
  //if cardFace is null then Cardid folder will return
  /**    ->localPath
   *       ->businesses
   *          ->code
   *             ->file*
   *       ->templates
   *          ->businesses
   *             ->svg|jpg
   *                ->code
   *                   ->files*
   *          ->personal
   *             ->svg|jpg
   *                ->code
   *                   ->files*
   *          ->inbuilt
   *             ->svg|jpg
   *                ->code
   *                   ->files*
   *       ->MyCards
   *          ->Temp
   *             ->front
   *             ->back
   *             ->icon
   *             ->config1.json
   *          ->CardName
   *             ->front
   *             ->back
   *             ->icon
   *             ->config1.json
   *       ->Cards
   *          ->Temp
   *             ->front
   *             ->back
   *             ->icon
   *          ->CardName
   *             ->front
   *             ->back
   *             ->icon
   **/
  String? path = localPath;
  logger.i(localPath);
  if (localPath != null) {
    //creating directories if they don't exist
    String tempPath ="$localPath/${isMine ? "myCards" : "cards"}${cardName == null ? "/temp" : "/"+cardName}";
    if (!Directory(tempPath).existsSync()) Directory(tempPath).createSync(recursive: true);
    //returning file or file directory
    return "$tempPath${(cardFace == null) ? "" : "/${getLatestCard?"latest":""}${cardFaceToString(cardFace)}.jpg"}";
  } else {
    return NO_IMAGE_FOUND;
  }
}
String getTemplateLocalPath({String? key, String? fileName,required String tempSubPath}){
  // key is Config and other extensions, config1->json
  // filename is name of the file like config1, front, back
  // code is a unique code of the template; for business code = bCode+tempCode
  if(key!=null&&fileName!=null){
    //deciding the file extension that will be downloaded
    if (key == "config") {
      int i = int.parse(fileName.toString().substring(6));
      switch (i) {
        case 1:
          fileName = "$fileName.json";
      }
    } else {
      fileName = "$fileName.$key";
    }
  }
  if (localPath != null) {
    //creating directories if they don't exist
    String tempPath ="$localPath/templates/$tempSubPath";
    if (!Directory(tempPath).existsSync()) Directory(tempPath).createSync(recursive: true);
    //returning file or file directory
    return "$tempPath/${fileName!=null?fileName:""}";
  } else {
    return NO_IMAGE_FOUND;
  }
}
String? getTemplateSubPath({required CardData cardData ,bool forLocal = false , String? code}){
  // this sub path is valid for firestore, storage and local storage
  if(cardData.templateName == null || cardData.templateName!["source"]==null)return null;
  // if the tempCode contains ~ then it is not backed up.
  String _tempCode = code ?? cardData.templateName!["tempCode"];
  _tempCode = _tempCode.replaceAll(unfinished,"");
  String _type = cardData.templateName!["templateType"];
  String _path = "templates/yunHi/$_type/$_tempCode";
  switch(cardData.templateName!["source"]){
    case "business":
      String _bCode = getSeparatedKeys(cardData.businessCode!)[0];
      _path = "businesses/$_bCode/$_path";
      break;
    case "inBuilt": _path = "$_path";
    break;
    case "personal":
      String globalId = cardData.globalId!;
      logger.wtf("mnu $forLocal ${cardData.globalId} $globalId");
      _path = "${!forLocal?"users/${globalId}":"myTemplates"}/$_path";
    break;
    default: return null;
  }
  logger.i("the subTempPath = $_path");
  return _path;
}
void askForStoragePermission(BuildContext context)async{
  ThemeData themeData = Theme.of(context);
  if (!(await Permission.storage.isGranted))
    AlacardDialog(
      context,
      child: Container(
        padding: EdgeInsets.all(medium),
        height: 5 * large,
        width: deviceWidth - large,
        decoration: BoxDecoration(
          color: themeData.backgroundColor,
          borderRadius: BorderRadius.circular(small),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Necessary Permission",
              style: themeData.textTheme.headline2,
            ),
            Opacity(opacity:0.7,
              child: Text(
                "Need the Storage Permission so that app generated data can be saved on device and you could use the app in offline mode.",
                style: themeData.textTheme.headline4,
                textAlign: TextAlign.center,
              ),
            ),
            Spacing().smallWiget,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ButtonType3(
                  height: medium*1.2,
                  width: large*2.2,
                  text: "Proceed",
                  offset: 0,
                  themeData: themeData,
                  isbnw: true,
                  bgColor: themeData.colorScheme.onPrimary.withOpacity(0),
                  onPressed: () async {
                    if(await Permission.storage.request().isGranted)Navigator.pop(bc_alacardDialogContext);
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
      )
    );
}
void gettingLocalPath() async {
  // getting location where all the data of app is stored
  final d = await getExternalStorageDirectory(); /// use getExternal directory for debugging and application doc dir for deployment, idk why await Permission.storage.isGranted was given before accessing directory
  localPath = d!.path;
}
Future<void> gettingLocalPathh() async {
  // getting location where all the data of app is stored
  final d = await getExternalStorageDirectory();
  localPath = d!.path;
  print("k k $localPath");
}
Future<void> getImage(BuildContext context, CardFace? cardFace,{required String source , bool isMine = false}) async {
  final progress = ProgressHUD.of(context)!;
  progress.show();
  ThemeData themeData = Theme.of(context);
  imageCache.clear();
  try {
    // step 1- picking the image
    final ImagePicker _picker = ImagePicker();
    XFile? image;
    switch(source) {
      case "camera":
        // Capture a photo
        image = await _picker.pickImage(source: ImageSource.camera);
        break;
      case "gallery":
        // picking an image
        image = await _picker.pickImage(source: ImageSource.gallery);
        break;
      default:
        progress.dismiss();
        return;
    }
    // to disappear loading when back button is pressed
    if (image == null) {
      progress.dismiss();
      return;
    }
    //Step 2- cropping the image
    CroppedFile? croppedImg = await ImageCropper().cropImage(
      // compressQuality: 90, this compressor does not work if image is not edited
      sourcePath: image.path,
      aspectRatioPresets: cardFace==CardFace.icon?
      [
        CropAspectRatioPreset.square
      ]:[
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: themeData.scaffoldBackgroundColor,
            toolbarWidgetColor: themeData.iconTheme.color,
            backgroundColor: themeData.scaffoldBackgroundColor,
            activeControlsWidgetColor: themeData.colorScheme.onPrimary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: cardFace==CardFace.icon,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    // handle error while cropping
    if (croppedImg == null) {
      // closing loader
      progress.dismiss();
      // deleting the chosen image
      File(image.path).deleteSync(recursive: true);
      return;
    }

    //Step 3- compressing and saving the image in desired location and delete the auto generated location
    // getting the destination path
    late String newPath;
    if(p_imageAsTemplateCode!=null){
     newPath = getTemplateLocalPath(tempSubPath: getTemplateSubPath(cardData: Provider.of<Variables>(context,listen: false).tempCardDetails , forLocal: true , code : p_imageAsTemplateCode)! , fileName: cardFaceToString(cardFace),key: "jpg" );
    }else {
     newPath = getCardImagePath(cardFace: cardFace , isMine: isMine);
    }
    logger.i("new path = $newPath");
    // compressing saving the cropped image to the final destination
    File? finalImg = await FlutterImageCompress.compressAndGetFile(
      croppedImg.path, newPath,
      quality: 90,
    );
    log("image pick final quality - ${await finalImg!.length()} ");
    // checking or creating new path with required directories
    if(!File(newPath).existsSync()){
      progress.dismiss();
      return;
    }
    //deleting unwanted images
    File(image.path).deleteSync(recursive: true);
    File(croppedImg.path).deleteSync(recursive: true);

    // setting up variable
    p_testImage = FileImage(File(newPath));
    // add the config file
    if(p_imageAsTemplateCode!=null){
      Map<String, dynamic>? _map = {
        "tempCode":p_imageAsTemplateCode,
        "source": "personal",
        "templateType": "jpg",
        "editable": true,
        "front": {
          "email": {
            "position": [0.5, 0.5],
            "lol":{}
          },
          "lol":"lol"
          ,},
        "back": {},
      };
      String _path = getTemplateLocalPath(tempSubPath: getTemplateSubPath(cardData: Provider.of<Variables>(context,listen: false).tempCardDetails , forLocal: true , code : p_imageAsTemplateCode)! , fileName:"config1",key: "config" );
      File(_path).writeAsStringSync(json.encode(_map));
    }
    //stop loader
    progress.dismiss();
    //now notify that image get is successful
    Provider.of<Variables>(context, listen: false).updateAreImagesEdited(cardFace!);
  } catch (e) {
    log("image pick error - ${e.toString()}");
  }
}
Future loadAlacardIconShadow() async{
  try {

    log("loadAlacardIconShadow");
    final tempDir = await getTemporaryDirectory();
    String path = "assets/icons/iconWithShadow.png";
    File iconFile = File('${tempDir.path}/iconWithShadow.png');

    if(iconFile.existsSync())return;
    log("loadAlacardIconShadow creating file");

    final bytes = await rootBundle.load(path);
    final list = bytes.buffer.asUint8List();
    final file = await iconFile.create();
    file.writeAsBytesSync(list);
  } catch (e) {
    log("loadAlacardIconShadow error - ${e.toString()} ");
  }
}
String getImagePath({CardData? cardData, CardFace? cardFace ,bool forDashboard = false , bool isMine = false , CRUD? crud}) {
  if(crud!=null ){
    if(crud==CRUD.read&& cardData!=null){
      String path = getCardImagePath(cardFace: cardFace , cardName : cardData.cardName,isMine: isMine);
      logger.wtf("shivalika ${cardFace.toString()},${cardData.cardName}: "+path);
      if (path != NO_IMAGE_FOUND && File(path).existsSync()) {
        return path;
      } else {
        return NO_IMAGE_FOUND;
      }
    }else{
      String path = getCardImagePath(cardFace: cardFace,isMine: isMine);
      logger.wtf("shivalika 1 : "+path);
      if (path != NO_IMAGE_FOUND && File(path).existsSync()) {
        return path;
      } else {
        return NO_IMAGE_FOUND;
      }
    }
  }
  // this function only returns path if image exists
  String path = getCardImagePath(cardFace: cardFace , isMine: isMine);
  //checking if temp is available
  if (File(path).existsSync()&& !forDashboard) {
    log("temp is available");
    return path;
  } else {
    log("temp is not available");
    path = (cardData != null)
        ? getCardImagePath(cardFace: cardFace, cardName: cardData.cardName , isMine: isMine)
        : NO_IMAGE_FOUND;
    log("the final $path");
    //check if original image is present
    if (path != NO_IMAGE_FOUND && File(path).existsSync()) {
      //log("4");
      return path;
    } else {
      //log("5");
      return NO_IMAGE_FOUND;
    }
  }
}

void AlacardDialog(BuildContext context, {Widget? child ,double barrierOpacity = 0.5}) {
  ThemeData themeData = Theme.of(context);
  showDialog(
      barrierColor: themeData.colorScheme.secondary.withOpacity(barrierOpacity),
      context: context,
      builder: (BuildContext dialogContext) {
        bc_alacardDialogContext = dialogContext;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(small),
          ),
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: child,
        );
      });
}

String? cardFaceToString(CardFace? cardFace) {
  return (cardFace != null) ? cardFace.toString().split(".")[1] : null;
}
String? cardTypeToFolderName(CardType cardType) {
  String temp;
  switch (cardType) {
    case CardType.mine:
      temp = "mycards";
      break;
    case CardType.manuallyAdded:
      temp = "cardsLocalAdded";
      break;
    case CardType.received:
      temp = "cardsReceived";
      break;
  }
  return temp;
}

openBottomSheet(BuildContext context , Widget bottomSheetWidget , {bool? isDragEnabled}) {
  return showModalBottomSheet(
    enableDrag: true,
    elevation: 5,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
    ),
    isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
       return bottomSheetWidget;
      });
}
Color getAdjustColor(Color baseColor, double amount) {
  Map<String, int> colors = {
    'r': baseColor.red,
    'g': baseColor.green,
    'b': baseColor.blue
  };

  colors = colors.map((key, value) {
    if (value + amount < 0) {
      return MapEntry(key, 0);
    }
    if (value + amount > 255) {
      return MapEntry(key, 255);
    }
    return MapEntry(key, (value + amount).floor());
  });
  return Color.fromRGBO(colors['r']!, colors['g']!, colors['b']!, 1);
}
//used to add images in both my card and manual card
Future saveManualCardImages(CardData cardData ,Map<CardFace , bool>  isImageUpdated ,{bool isMine = false})async {
  //todo the isImageUpdated provider variable is not available
  //log("are images edited ${isImageUpdated.toString()}");
  try {
    logger.i("${cardData.cardName} : edited images = $isImageUpdated");
    CardFace.values.forEach((_cardFace) {
        bool isUpdated = isImageUpdated[_cardFace]!; // this will be true even for template card
        String oldPath = getImagePath(cardFace: _cardFace , isMine: isMine);
        logger.i("oldPath --> $oldPath , cardName --> ${cardData.cardName}");
        if(isUpdated && oldPath!=NO_IMAGE_FOUND){
          log("yo1");
          String newPath = getCardImagePath(cardFace: _cardFace,cardName:cardData.cardName , isMine: isMine);
          File(oldPath).copySync(newPath);
          log("yo2");
          //checking if successful
          if(File(newPath).existsSync()){
            logger.i("${cardData.cardName} : success oldPath->newPath = $oldPath -> $newPath");
            //log("${_cardFace.toString()} is saved in proper location and new path is $newPath & $oldPath and ${cardData.cardName}");
          }else{
            logger.e("${cardData.cardName} : failed oldPath->newPath = $oldPath -> $newPath");
            //log("${_cardFace.toString()} unable to save");
          }
          log("yo3");
          //deleting temp image
          File(oldPath).deleteSync(recursive: true);
          log("yo4");
        }
        // deleting the images that have isUpdated tag but no temp image
        else if(isUpdated && oldPath==NO_IMAGE_FOUND){
          String newPath = getCardImagePath(cardFace: _cardFace,cardName:cardData.cardName , isMine: isMine);
          if(File(newPath).existsSync()){
            //deleting saved image
            File(newPath).deleteSync(recursive: true);
          }
          // now while backup if no orignal image is found then delete the image from cloud and mark the token null
        }
      });
    return "done";
  } catch (e) {
    return e.toString();
  }
}
void creatingTempImages(String cardName,bool isMine){
  for(CardFace cf in CardFace.values){
    File _file = File(getCardImagePath(cardFace: cf,cardName: cardName, isMine: isMine));
    if(_file.existsSync()){
      _file.copySync(getCardImagePath(cardFace: cf, isMine: isMine));
    }
  }
}
void deletingTempImages(bool isMine){
  for(CardFace cf in CardFace.values){
    File _file = File(getCardImagePath(cardFace: cf, isMine: isMine));
    if(_file.existsSync()){
      _file.deleteSync(recursive: true);
    }
  }
}
UiModes? getThemeModeFromString(String string){
  for(UiModes themeMode in UiModes.values){
    if(themeMode.toString()==string){
      return themeMode;
    }
  }
}

bool isBusinessCard(CardData? _cardData){
  bool temp = false;
  if(_cardData==null)return temp;
  try {
    if(_cardData.templateName!["tempCode"].toString().length!=0&&_cardData.businessCode!.length>0){
      temp = true;
    }
  } catch (e) {
    log(e.toString());
  }
  return temp;
}
bool isTemplate(CardData? cardData) {
  bool temp = false;
  if(cardData==null)return temp;
  // todo instead of this please make sure to add tempCode over here or something better
  if(p_imageAsTemplateCode!=null) return true;
  try {
    if( cardData.templateName!=null&&cardData.templateName!["tempCode"]!=null&&cardData.templateName!["tempCode"]!=""){
      temp = true;
    }
  } catch (e) {
    logger.e(e);
  }
  return temp;
}
bool isMyImageTemplateCodeAvailable(String code , CardData cardData){
  bool temp = true;
  try{
    if(File(getTemplateLocalPath(tempSubPath: getTemplateSubPath(cardData: cardData,forLocal: true,code: code)??"yo bro")).existsSync()){
      temp = false;
    }
  }
  catch(e){
    logger.e(e);
    temp = true;
  }
  return temp;
}
String getRandomId(){
  math.Random random = math.Random();
  String chars ="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz";
  int charsLength = chars.length;
  String generatedPin = '';

  for (int i = 0; i < 6; i++) {
    generatedPin += chars[random.nextInt(charsLength)];
  }
  return generatedPin;
}
String? getNewMyImageTemplateId(CardData? cardData){
  if(cardData==null) return null;
  String temp = getRandomId();
  if(isMyImageTemplateCodeAvailable(temp, cardData)){
    // returning id with un backed up tag
    return unfinished+temp;
  } else {
    return getNewMyImageTemplateId(cardData);
  }
}
enum UrlOp {
  phone,
  email,
  link,
  map
}
void dynamicUrlOps({UrlOp urlOp = UrlOp.link, required dynamic data}) async{
  String _url = "";
  switch(urlOp){
    case UrlOp.phone:
      _url = "tel:$data";
      break;
    case UrlOp.email:
      _url = "mailto:$data?subject= &body= ";
      break;
    case UrlOp.link:
      if(data.startsWith("http")){
        _url = data;
      }else{
        _url = "https://$data";
      }
      break;
    case UrlOp.map:
      if(data.position!=[0,0]) {
        _url ="https://www.google.com/maps/search/?api=1&query=${data.position[0]}%2C${data.position[0]}";
      }
      if(data.address!=""){
        // ecodind for url
        String temp = data.address;
        temp.replaceAll("|", "%7C");
        temp.replaceAll(",","%2C");
        temp.replaceAll(" ", "+");
        _url ="https://www.google.com/maps/search/?api=1&query=$temp";
      }
      break;
  }
  await canLaunch(_url) ? await launch(_url) : logger.e("cannot launch $_url");
}
enum MessageType{
  error,success,info
}
AlacardSnackBar(BuildContext? context, String message, {MessageType type = MessageType.info, Duration? duration}){
  ThemeData themeData = Theme.of(context??bc_currContext!);
  late Color fontColor;
  late Color bgColor;
  TextStyle ts = themeData.textTheme.subtitle1!;
  if(themeData.backgroundColor==Color(0xFF2b394e)){
    // dark theme
    bgColor = Colors.grey.shade900;
    fontColor = ts.color!;
  } else {
    // light theme
    bgColor = Colors.grey;
    fontColor = Colors.white70;
  }
  switch(type){
    case MessageType.error:
      fontColor = themeData.errorColor;
      break;
    case MessageType.success:
      fontColor = themeData.focusColor;
      break;
    default:
      break;
  }
  ScaffoldMessenger.of(context??bc_currContext!).showSnackBar(
      SnackBar(
        padding: EdgeInsets.fromLTRB(medium, 0, medium, medium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(small),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: SizedBox(
          height: large*0.7,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(large),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(large),
                ),
                color: bgColor.withOpacity(0.8),
                elevation: 0,
                child: Center(child: Text(message,
                  style: TextStyle(
                    fontFamily: ts.fontFamily,
                    fontSize: ts.fontSize,
                    color: fontColor
                  )))
              ),
            ),
          ),
        ),
        duration: duration??Duration(milliseconds: 1000),
      )
  );

}
void showAlacardOverlayNotification(String title, String subtitle){
  showOverlayNotification((context){
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top,right: 5,left: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(small),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(small),
            ),
            color: Colors.grey.shade900.withOpacity(0.5),
            elevation: 0,
            child: ListTile(
              title: Text(title,style: TextStyle(
                  fontFamily: "OpenSans",
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16.0,
                  letterSpacing: 1
              ),),
              leading: SizedBox.fromSize(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(small),
                    child: Image.asset("assets/icons/icon.png"),)),
              subtitle: Text(subtitle, style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontFamily: "OpenSans",
                fontSize: 12.0,
              ),),
            ),
          ),
        ),
      ),
    );
  });
}
Future<String> deviceUniqueId() async {
  var deviceInfo = DeviceInfoPlugin();
  String? temp;
  if (Platform.isIOS) { // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    temp = iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    temp = androidDeviceInfo.androidId; // unique ID on Android
  }
  logger.i("the unique id is : $temp");
  return temp??"itsNotYouItsMe";
}

String getFieldData(String fieldName,{listen = false}){
  Map<String,String?>? _map = Provider.of<TemplateData>(bc_currContext!,listen: listen).tempCardMapData();
  String? s;
  if(_map!=null&&_map[fieldName]!=null){
    s = "";
    log("adada $fieldName-- ${_map[fieldName]}");
    switch(fieldName){
      case "address" : {
        Address? add = stringToAddress(_map[fieldName]);
        if(add!=null && add.address!=""){
          log("adada ${add.toStringWithSeparator()}");
          s = add.address;
        } else {
          log("adada =");
          s = null;
        }
        break;}
      case "socialMedias" : {
        String seperator = "\n";
        // if(positions!["socialMedias"]["organize"]==null||positions!["socialMedias"]["organize"]["align"]==null||positions!["socialMedias"]["organize"]["align"]=="-"){
        //   seperator = " ";
        // }else{
        //   seperator = "\n";
        // }
        List<SocialMedia> cList = stringToSocialMedias(_map[fieldName]);
        if(cList.length==0){
          s = null;break;
        }
        for(SocialMedia x in cList){
          s="$s${x.username}$seperator";
        }
        break;
      }
      case "contactNos" : {
        String seperator = "\n";
        List<ContactNo> cList = stringToContactNos(_map[fieldName]);
        if(cList.length==0){
          s = null;break;
        }
        for(ContactNo x in cList){
          s="$s${x.countryCode} ${x.number}$seperator";
        }
        break;
      }
      case "customFields" : {
        String seperator = "\n";
        List<CustomField> cList = stringToCustomFields(_map[fieldName]);
        if(cList.length==0){
          s = null;break;
        }
        for(CustomField x in cList){
          s="$s${x.heading} ${x.fieldData.toString()}$seperator";
        }
        break;
      }
      default: {
        s=_map[fieldName];
      }
    }
  }
  return (s==null || s =="")?"No $fieldName":s;
}

Future<bool> templateToImage() async{
  try {
    if(p_templateImage==null) return false;

    final _image = p_templateImage!;
    final recorder = UI.PictureRecorder();
    final canvas = Canvas(recorder);
    List<String> displayList =  Provider.of<TemplateData>(bc_currContext!,listen: false).displayList!;
    log("asdfg $displayList $p_templateMap");
    // building canvas
    Paint _paint = Paint();
    canvas.save();
    canvas.drawImage(_image,Offset.zero,_paint);
    canvas.restore();
    // style
    // getting text style
    for (String fieldName in displayList) {
      log("asdfg 1 $fieldName");
      if(fieldName=="lol") continue; // just a flag
      double scale = (_image.width/(deviceWidth - medium))*0.9;
      late TextStyle _ts;
      try {
        _ts = PickerFont(fontFamily: p_templateMap[fieldName]["fontStyle"]["fontFamily"]).toTextStyle();
      } catch (e) {
        // todo displaySnackBar(context, "${_templateMap[fieldName]["fontStyle"]["fontFamily"]} font is not fount!");
        _ts = Theme.of(bc_currContext!).textTheme.headline2!;
        logger.e(e);
      }
      TextStyle _style = TextStyle(
        color:  Color.fromRGBO(p_templateMap[fieldName]["fontStyle"]["color"][0], p_templateMap[fieldName]["fontStyle"]["color"][1], p_templateMap[fieldName]["fontStyle"]["color"][2], p_templateMap[fieldName]["fontStyle"]["color"][3]*1.0),
        fontSize: p_templateMap[fieldName]["fontStyle"]["size"]*1.0*scale,
        fontFamily: _ts.fontFamily,
      );
      // get the text data
      String data = getFieldData(fieldName);
      // position
      final offset = Offset(p_templateMap[fieldName]["position"][0]*_image.width, p_templateMap[fieldName]["position"][1]*_image.height);

      log("asdfg 2 ${offset.dx} ${p_templateMap[fieldName]["fontStyle"]["size"]*1.0*scale}");
      final textSpan = TextSpan(
        text: data,
        style: _style,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        maxLines: (fieldName=="contactNos"||fieldName=="socialMedias"||fieldName=="customFields")?null:1
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: _image.width*1.0,
      );
      textPainter.paint(canvas, offset);
    }
    // converting to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(_image.width, _image.height);
    final byteData = await img.toByteData(format: UI.ImageByteFormat.png);

    // compressing image
    final finalImg = await FlutterImageCompress.compressWithList(
      byteData!.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      quality: 90,
    );
    final file = File(getCardImagePath(isMine: true, cardFace: CardFace.front));
    await file.writeAsBytes(finalImg);
    return true;
  } catch (e) {
    log("asdfg $e");
    return false;
  }
}

List<CardData> quickSort(List<CardData> list, int low, int high) {
  if (low < high) {
    int pi = partition(list, low, high);
    log("pivot: ${list[pi]} now at index $pi");

    quickSort(list, low, pi - 1);
    quickSort(list, pi + 1, high);
  }
  return list;
}

int partition(List<CardData> list, low, high) {
  // Base check
  if (list.isEmpty) {
    return 0;
  }
  // Take our last element as pivot and counter i one less than low
  int pivot = getEpochForSort(list[high]);

  int i = low - 1;
  for (int j = low; j < high; j++) {
    // When j is < than pivot element we increment i and swap arr[i] and arr[j]
    if (getEpochForSort(list[j]) < pivot) {
      i++;
      swap(list, i, j);
    }
  }
  // Swap the last element and place in front of the i'th element
  swap(list, i + 1, high);
  return i + 1;
}

// Swapping using a temp variable
void swap(List<CardData> list, int i, int j) {
  CardData temp = list[i];
  list[i] = list[j];
  list[j] = temp;
}

int getEpochForSort(CardData cardData){
  if(cardData.cardType==CardType.mine||cardData.cardType==CardType.manuallyAdded){
    return cardData.dateTimeCreated!.millisecondsSinceEpoch;
  } else {
    return cardData.dateTimeUpdated!.millisecondsSinceEpoch;
  }
}