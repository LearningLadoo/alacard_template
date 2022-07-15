import 'dart:convert';
import 'dart:io';
import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/database/cardFields/address.dart';
import 'package:alacard_template/database/databaseHelper.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/providers/cardsMapProvider.dart';
import 'package:alacard_template/providers/templateData.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/template/templateCardFace.dart';
import '../../utils/common/cardFaceWidget.dart';
import 'package:alacard_template/utils/common/displayContacts.dart';
import 'package:alacard_template/utils/common/displayCustom.dart';
import 'package:alacard_template/utils/common/displaySocial.dart';
import 'package:alacard_template/utils/common/textField.dart';
import 'package:alacard_template/screens/manageCardDetails/utils/addContacts.dart';
import 'package:alacard_template/screens/manageCardDetails/utils/addCustom.dart';
import 'package:alacard_template/utils/common/manageNote.dart';
import 'package:alacard_template/screens/manageCardDetails/utils/addSocial.dart';
import 'package:alacard_template/utils/common/myCardSlider.dart';
import 'package:alacard_template/utils/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

final String _TAG = "Manage-Card-Details-Screen";

bool _isFavourite = false;

class ManageCardDetails extends StatefulWidget {
  CRUD crud;
  String? index;
  ManageCardDetails({this.crud = CRUD.create, this.index,});

  @override
  _ManageCardDetailsState createState() => _ManageCardDetailsState();
}

class _ManageCardDetailsState extends State<ManageCardDetails> {
  CardData _cardData = CardData();
  late bool addingNewCard , isBusiness=false;
  late CardsMapProvider _cardDashboardProvider;
  late TemplateData _templateDataProvider;
  final formKey = GlobalKey<FormState>();
  List<dynamic> unEditable = [];
  bool allowToPop = true;
  @override
  void initState() {
    try {
      logger.i(widget.index);
      _templateDataProvider = Provider.of<TemplateData>(context, listen: false);
      _cardDashboardProvider = Provider.of<CardsMapProvider>(context, listen: false);
      //getting cardData
      switch (widget.crud) {
            case CRUD.create:
              addingNewCard = true;
              deletingTempImages(true);
              break;
            case CRUD.update:
              logger.i(_cardDashboardProvider.userCardsMap.toString());
              if(_cardDashboardProvider.userCardsMap.isNotEmpty){
                _cardData = _cardDashboardProvider.userCardsMap[widget.index!]!.clone();
                _templateDataProvider.updateMyCardTempData(_cardData);
                logger.i("manage card details ${_cardData}");
                unEditable.add("email");
              }
              //make temp images of front,back and icon if their real images exists
              creatingTempImages(_cardData.cardName!,true);
              addingNewCard = false;
              break;
            default:
          }
      // checking is business and getting uneditable list
      if(isBusinessCard(_cardData)){
            isBusiness = true;
            unEditable = _cardData.templateName!["unEditable"];
            unEditable.add("email");
            logger.i(unEditable);
          }
      logger.i("hello -1 ${_cardData!=null}");
      //setting social, contacts, customs and note by updating temp card Details
      var _providerVariables = Provider.of<Variables>(context,listen: false);
      _providerVariables.updateTempCard(_cardData);
    } catch (e) {
      logger.e(e);
    }
    super.initState();
  }
  Future<bool> getExitDialog() async{
    AlacardDialog(context, child: ExitDialog(context));
    return false;
  }
@override
  void dispose() {
    deletingTempImages(true);
    p_imageAsTemplateCode = null;
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
     bc_manageCardContext = context;
     bc_currContext = context;
    printWithTag("the local path id $localPath");
    ThemeData themeData = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(context).unfocus();
        return allowToPop?(await getExitDialog()):false;
      },
      child: OnWidgetLoader(
        themeData: themeData,
        child: Builder(
          builder: (context) => Scaffold(
            appBar: AlacardAppBar(
                context,
                askBeforeExiting: widget.crud==CRUD.read?false:true,
                screen: r_manageCards,
                displayBack: true,
                title: UnfocusKeyboardOnTap(
                  context,
                  child: SizedBox(
                    width: deviceWidth-2*large,
                    child: Center(
                      child: Text(
                        "My Card",
                        style: themeData.textTheme.headline1,
                      ),
                    ),
                  ),
                ),
                actions: [
                  Container(
                      width: large,
                      padding: EdgeInsets.all(tiny/2),
                      child : ClipRRect(
                          borderRadius: BorderRadius.circular(small),
                          child: CardFaceWidget(crud: widget.crud,cardFace: CardFace.icon,size: 1.0,cardData: (!addingNewCard)?_cardData:null, isMine: true,)
                      )
                  )
                ]
            ),
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: UnfocusKeyboardOnTap(
                context,
                child: SizedBox(
                  width: deviceWidth,
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Spacing().smallWiget,
                        // add images and below icons
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            //images
                            (isTemplate(_templateDataProvider.myCardTempData??_cardData)||p_imageAsTemplateCode!=null)?TemplateCardFace(_cardData,crud: widget.crud,):MyCardSlider(crud: widget.crud,cardData:(!addingNewCard)?_cardData:null),
                          ],
                        ),
                        //todo : add suggestion AI widget
                        Spacing().mediumWidget,
                        Spacing().smallWiget,
                        //name
                        EmbossedTextField(
                          isSelected: isTemplate(_cardData)&&(_templateDataProvider.displayList??[]).contains("name"),
                          enabled: !unEditable.contains("name"),
                          initialValue: _cardData.name??"",
                          text: "Name",
                          themeData: themeData,
                          width: deviceWidth * 0.9,
                          height: 6*small,
                          onSelectField: !(true&&isTemplate(_cardData))?null:(isSelected){
                            if(!true) return;
                            logger.i("issss ${isTemplate(_cardData)} ${_cardData.templateName!["editable"]} $p_imageAsTemplateCode");
                            if(isTemplate(_cardData)&&_cardData.templateName!["editable"])
                            {if(isSelected)_templateDataProvider.updateDisplayList(CRUD.update, newValues: ["name"]);
                            if(!isSelected)_templateDataProvider.updateDisplayList(CRUD.delete, newValues: ["name"]);
                            }
                          },
                          onChangedFn: (value) {
                            _cardData.name = value;
                          },
                          onEditingComplete: (value) {
                            logger.wtf("kool");
                            _cardData.name = value;
                            _templateDataProvider.updateMyCardTempData(_cardData);
                            FocusScope.of(context).unfocus();
                          },
                          validatorFn: (value) {
                            if(value!=null){
                              _cardData.name = value;
                            }
                          },
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.name,
                        ),
                        Spacing().tinyWidget,
                        //Title
                        EmbossedTextField(
                          isSelected: true&&isTemplate(_cardData)&&(_templateDataProvider.displayList??[]).contains("title"),
                          enabled: !unEditable.contains("title"),
                          initialValue: _cardData.title??"",
                          text: "Title",
                          themeData: themeData,
                          width: deviceWidth * 0.9,
                          height: 6*small,
                          onSelectField: !(true&&isTemplate(_cardData))?null:(isSelected){
                            if(!true) return;
                            if(isTemplate(_cardData)&&_cardData.templateName!["editable"])
                            {if(isSelected)_templateDataProvider.updateDisplayList(CRUD.update, newValues: ["title"]);
                            if(!isSelected)_templateDataProvider.updateDisplayList(CRUD.delete, newValues: ["title"]);
                            }
                          },
                          onChangedFn: (value) {
                            _cardData.title = value;
                          },
                          onEditingComplete: (value) {
                            _cardData.title = value;
                            _templateDataProvider.updateMyCardTempData(_cardData);
                            FocusScope.of(context).unfocus();
                          },
                          validatorFn: (value) {
                            if(value!=null){
                              _cardData.title = value;
                            }},
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                        ),
                        Spacing().tinyWidget,
                        //Company Name
                        EmbossedTextField(
                          isSelected: true&&isTemplate(_cardData)&&(_templateDataProvider.displayList??[]).contains("businessName"),
                          enabled: !unEditable.contains("businessName"),
                          initialValue: _cardData.businessName??"",
                          text: "Company",
                          themeData: themeData,
                          width: deviceWidth * 0.9,
                          height: 6*small,
                          onSelectField: !(true&&isTemplate(_cardData))?null:(isSelected){
                            if(!true) return;
                            if(isTemplate(_cardData)&&_cardData.templateName!["editable"])
                            {if(isSelected)_templateDataProvider.updateDisplayList(CRUD.update, newValues: ["businessName"]);
                            if(!isSelected)_templateDataProvider.updateDisplayList(CRUD.delete, newValues: ["businessName"]);
                            }
                          },
                          onChangedFn: (value) {
                            _cardData.businessName = value;
                          },
                          onEditingComplete: (value) {
                            _cardData.businessName = (value==""||value == null)?"Business Name":value;
                            _templateDataProvider.updateMyCardTempData(_cardData);
                            FocusScope.of(context).unfocus();
                          },
                          validatorFn: (value) {

                            if(value!=null){
                              _cardData.businessName = value;
                            }
                          },
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.name,
                        ),
                        Spacing().tinyWidget,
                        //Email Id
                        EmbossedTextField(
                          isSelected: true&&isTemplate(_cardData)&&(_templateDataProvider.displayList??[]).contains("email"),
                          enabled: !unEditable.contains("email"),
                          initialValue: _cardData.email??"",
                          text: "Email ID",
                          themeData: themeData,
                          width: deviceWidth * 0.9,
                          height: 6*small,
                          onSelectField: !(true&&isTemplate(_cardData))?null:(isSelected){
                            if(!true) return;
                            if(isTemplate(_cardData)&&_cardData.templateName!["editable"])
                            {if(isSelected)_templateDataProvider.updateDisplayList(CRUD.update, newValues: ["email"]);
                            if(!isSelected)_templateDataProvider.updateDisplayList(CRUD.delete, newValues: ["email"]);
                            }
                          },
                          onChangedFn: (value) {
                            _cardData.email = value;
                          },
                          onEditingComplete: (value) {
                            _cardData.email = value;
                            _templateDataProvider.updateMyCardTempData(_cardData);
                            FocusScope.of(context).unfocus();
                          },
                          validatorFn: (value) {
                            final pattern = r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)';
                            final regExp = RegExp(pattern);

                            if (value != null && value != "") {
                              if (!regExp.hasMatch(value)) {
                                return 'Enter a valid email';
                              } else {
                                _cardData.email = value;
                                return null;
                              }
                            }
                          },
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        Spacing().tinyWidget,
                        //Address
                        EmbossedTextField(
                          isSelected: true&&isTemplate(_cardData)&&(_templateDataProvider.displayList??[]).contains("address"),
                          enabled: !unEditable.contains("address"),
                          initialValue: _cardData.address!=null?_cardData.address!.address:"",
                          text: "Address",
                          themeData: themeData,
                          width: deviceWidth * 0.9,
                          height: 6*small,
                          onSelectField: !(true&&isTemplate(_cardData))?null:(isSelected){
                            if(!true) return;
                            if(isTemplate(_cardData)&&_cardData.templateName!["editable"])
                            {if(isSelected)_templateDataProvider.updateDisplayList(CRUD.update, newValues: ["address"]);
                            if(!isSelected)_templateDataProvider.updateDisplayList(CRUD.delete, newValues: ["address"]);
                            }
                          },
                          onChangedFn: (value) {
                            _cardData.address = Address(address:value);
                          },
                          onEditingComplete: (value) {
                            _cardData.address = Address(address:value);
                            _templateDataProvider.updateMyCardTempData(_cardData);
                            FocusScope.of(context).unfocus();
                          },
                          validatorFn: (value) {
                            if(value!=null){
                              _cardData.address = Address(address:value);
                            }
                          },
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.name,
                        ),
                        Spacing().tinyWidget,
                        //Website
                        EmbossedTextField(
                          isSelected: true&&isTemplate(_cardData)&&(_templateDataProvider.displayList??[]).contains("website"),
                          enabled: !unEditable.contains("website"),
                          initialValue: _cardData.website??"",
                          text: "Website",
                          themeData: themeData,
                          width: deviceWidth * 0.9,
                          height: 6*small,
                          onSelectField: !(true&&isTemplate(_cardData))?null:(isSelected){
                            if(!true) return;
                            if(isTemplate(_cardData)&&_cardData.templateName!["editable"])
                            {if(isSelected)_templateDataProvider.updateDisplayList(CRUD.update, newValues: ["website"]);
                            if(!isSelected)_templateDataProvider.updateDisplayList(CRUD.delete, newValues: ["website"]);
                            }
                          },
                          onChangedFn: (value) {
                            _cardData.website = value;
                          },
                          onEditingComplete: (value) {
                            _cardData.website = value;
                            _templateDataProvider.updateMyCardTempData(_cardData);
                            FocusScope.of(context).unfocus();
                          },
                          validatorFn: (value) {
                            if(value!=null){
                              _cardData.website = value;
                            }},
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.url,
                        ),
                        Spacing().tinyWidget,
                        //About
                        EmbossedTextField(
                          isSelected: true&&isTemplate(_cardData)&&(_templateDataProvider.displayList??[]).contains("about"),
                          enabled: !unEditable.contains("about"),
                          initialValue: _cardData.about??"",
                          text: "About",
                          themeData: themeData,
                          width: deviceWidth * 0.9,
                          height: 6*small,
                          onSelectField: !(true&&isTemplate(_cardData))?null:(isSelected){
                            if(!true) return;
                            if(isTemplate(_cardData)&&_cardData.templateName!["editable"])
                            {if(isSelected)_templateDataProvider.updateDisplayList(CRUD.update, newValues: ["about"]);
                            if(!isSelected)_templateDataProvider.updateDisplayList(CRUD.delete, newValues: ["about"]);
                            }
                          },
                          onChangedFn: (value) {
                            _cardData.about = value;
                          },
                          onEditingComplete: (value) {
                            _cardData.about = value;
                            _templateDataProvider.updateMyCardTempData(_cardData);
                          },
                          validatorFn: (value) {
                            if(value!=null){
                              _cardData.about = value;
                            }},
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.url,
                        ),
                        //Add Contacts with bottom sheet
                        DisplayContacts(enabled: !unEditable.contains("contactNos")),
                        Spacing().smallWiget,
                        ButtonType1(
                          offset: themeMode==ThemeMode.dark?4:8,
                          enabled: !unEditable.contains("contactNos"),
                          text: "Add Contacts",
                          themeData: themeData,
                          width: deviceWidth*0.9,
                          height: 4.8*small,
                          onSelectButton: !(true&&isTemplate(_cardData))?null:(isSelected){
                            if(!true) return;
                            // todo contact nos tag is wrong
                            if(isTemplate(_cardData)&&_cardData.templateName!["editable"])
                            {if(isSelected)_templateDataProvider.updateDisplayList(CRUD.update, newValues: ["contactNos"]);
                            if(!isSelected)_templateDataProvider.updateDisplayList(CRUD.delete, newValues: ["contactNos"]);
                            }
                          },
                          isSelected: true&&isTemplate(_cardData)&&(_templateDataProvider.displayList??[]).contains("contactNos"),
                          textStyle: themeData.textTheme.subtitle2,
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            openBottomSheet(context, AddContacts(crud: CRUD.create));
                          },
                        ),
                        SizedBox(height: small*1.6,),
                        //Add Social Media with bottom sheet
                        DisplaySocial(enabled: !unEditable.contains("socialMedias"),),
                        Spacing().smallWiget,
                        ButtonType1(
                          offset: themeMode==ThemeMode.dark?4:8,
                          enabled: !unEditable.contains("socialMedias"),
                          text: "Add Social Media",
                          themeData: themeData,
                          width: deviceWidth * 0.9,
                          height: 4.8*small,
                          onSelectButton: !(true&&isTemplate(_cardData))?null:(isSelected){
                            if(!true) return;
                            if(isTemplate(_cardData)&&_cardData.templateName!["editable"])
                            {if(isSelected)_templateDataProvider.updateDisplayList(CRUD.update, newValues: ["socialMedias"]);
                            if(!isSelected)_templateDataProvider.updateDisplayList(CRUD.delete, newValues: ["socialMedias"]);
                            }
                          },
                          isSelected: true&&isTemplate(_cardData)&&(_templateDataProvider.displayList??[]).contains("socialMedias"),
                          textStyle: themeData.textTheme.subtitle2,
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            openBottomSheet(context, AddSocial(crud: CRUD.create));
                          },
                        ),
                        SizedBox(height: small*1.6,),
                        //Add Custom Fields with bottom sheet
                        DisplayCustomField(enabled: !unEditable.contains("customFields")),
                        Spacing().smallWiget,
                        ButtonType1(
                          offset: themeMode==ThemeMode.dark?4:8,
                          enabled: !unEditable.contains("customFields"),
                          text: "Add Custom",
                          themeData: themeData,
                          width: deviceWidth * 0.9,
                          height: 4.8*small,
                          textStyle: themeData.textTheme.subtitle2,
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            openBottomSheet(context, AddCustom(crud: CRUD.create));
                          },
                        ),
                        SizedBox(height: small*2.8,),
                        // Save Button
                        ButtonType3(
                            height: medium*2,
                            width: screenWidth(context) * 0.9,
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              final progressHUD = ProgressHUD.of(context)!;
                              progressHUD.showWithText("saving...");
                              setState((){allowToPop = false;});
                              if (formKey.currentState!.validate()) {
                                Variables _tempCardProvider = Provider.of<Variables>(context,listen: false);
                                // todo to mark updated, check if the front data is same as in its config file, if no config file then mark updated
                                if(isTemplate(_cardData)){
                                  logger.e("all providers are as myCardTempData ${_templateDataProvider.myCardTempData!.getMapFromCardData()}");
                                  logger.e("all providers are as tempCardDetails ${_tempCardProvider.tempCardDetails.getMapFromCardData()}");
                                  String pathMyCards = getCardImagePath(cardName: _cardData.cardName , isMine: true);
                                  bool isUpdatedTemp = false;
                                  if (File("$pathMyCards/config1.json").existsSync()){
                                    // check if data is same to mark updated
                                    Map<String, dynamic> _map = json.decode(File("$pathMyCards/config1.json").readAsStringSync());
                                    isUpdatedTemp = _cardData.templateName!["front"].toString()!=_map["front"].toString();
                                  } else {
                                    // mark is updated
                                    isUpdatedTemp = true;
                                  }
                                  if(isUpdatedTemp){
                                    // make canvas to image in temp folder
                                    bool isSuccess = await templateToImage();
                                    if(!isSuccess){
                                      // todo handle failure
                                    }
                                    //save the is updated state in provider
                                    Provider.of<Variables>(context, listen: false).updateAreImagesEdited(CardFace.front,doNotify: false);
                                  }
                                }
                                CardData _tempCardFromProvider = _tempCardProvider.tempCardDetails;
                                _cardData.contactNos = _tempCardFromProvider.contactNos;
                                _cardData.socialMedias =_tempCardFromProvider.socialMedias;
                                _cardData.customFields = _tempCardFromProvider.customFields;
                                _cardData.dateTimeUpdated = DateTime.now().toUtc();
                                if(_cardData.imageTokens==null){
                                  _cardData.imageTokens = {CardFace.front: null,CardFace.back: null,CardFace.icon: null};
                                }
                                CardData? templateCardData = _templateDataProvider.myCardTempData;
                                _cardData.templateName = (templateCardData!=null && isTemplate(templateCardData))?templateCardData.templateName:null;
                                if (addingNewCard) {
                                  logger.i("yeahhhh 1.1");
                                  _cardData.dateTimeCreated = DateTime.now().toUtc();
                                  //adding on device
                                  await DatabaseHelper(context).addCardOnDevice(_cardData);
                                } else {
                                  logger.i("yeahhhh 1.2 ");
                                  //updating old card
                                  await DatabaseHelper(context).updateCard(_cardData);
                                }
                                logger.i("yeahhhh 2");
                                _templateDataProvider.updateMyCardTempData(null);
                                _tempCardProvider.clearTempCard();
                                Navigator.pop(context);
                              }
                              setState((){allowToPop = true;});
                              progressHUD.dismiss();
                            },
                            themeData: themeData,
                            text: " Save "),
                        SizedBox(height: small*1.6,),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),);
  }
}

void printWithTag(String text) {
  print("$_TAG : $text");
}
