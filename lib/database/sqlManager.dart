import 'dart:developer';
import 'dart:math' as math;
import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/database/sharedPrefsOfUser.dart';
import 'package:alacard_template/functions.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';

class SqlManager{

Database? _database;

String cardTable = "CardsDatabase";
String myCardTable = "MyCardsDatabase";
String businessDetailsTable = "businessDetails";
String sharedPrefsTable  ="SharedPrefs";
String receivedCards  ="ReceivedCards";

String colCardName = "cardName";
String colName = "name";
String colNote = "note";
String colAbout = "about";
String colTitle = "title";
String colEmail = "email";
String colBusinessName = "businessName";
String colGroup = "groupName";
String colWebsite = "website";
String colGlobalID = "globalId";
String colContactNos = "contactNos";
String colSocialMedias = "socialMedias";
String colAddress = "address";
String colCustomFields = "customFields";
String colDateTimeCreated = "dateTimeCreated";
String colDateTimeUpdated = "dateTimeUpdated";
String colUpdateHistory = "updatesHistory";
String colIsUpdated = "isUpdated";
String colFav = "isFavourite";
String colAuthentic = "isAuthentic";
String colNickName  = "nickName";
String colBusinessCode  = "businessCode";
String colIsAnalytics  = "isAnalytics";
String colIsSecureSharing  = "isSecureSharing";
String colCardsLeft  = "cardsLeft";
String colCardType = 'cardType';
String colImageTokens = "imageTokens";
String coltemplateName = "templateName";

String colLocalEditable = "localEditable";

String colPassword = "pass";
String colSharingPreferences = 'sharingPreferences';
String colScreenGuide = "screenGuide";
String colPendingUIDs = "pendingUIDs";
String colIsMinimal = "isMinimal";
String colThemeMode = "themeMode";
String Tag = "databaseHelper";

  SqlManager(){
    openDb();
  }
  Future openDb() async {
    if (_database == null) {
      _database = await openDatabase(
          join(await getDatabasesPath(), "cardDatabase", "database.db"),
          version: 1, onCreate: (Database db, int version) async {
        await db.execute(
            "CREATE TABLE $cardTable($colCardName TEXT PRIMARY KEY ,$colName TEXT, $colNote TEXT, $colAbout TEXT, $colTitle TEXT, $colEmail TEXT,$colBusinessName TEXT ,$colGroup TEXT , $colWebsite TEXT,  $colGlobalID TEXT, $colContactNos TEXT, $colSocialMedias TEXT, $colAddress text , $colCustomFields TEXT, $colDateTimeCreated TEXT,$colDateTimeUpdated TEXT, $colUpdateHistory TEXT, $colIsUpdated TEXT, $colFav TEXT, $colAuthentic Text , $colCardType TEXT, $colImageTokens TEXT,$coltemplateName TEXT,$colBusinessCode TEXT )"
        );
        await db.execute(
            "CREATE TABLE $receivedCards($colCardName TEXT PRIMARY KEY ,$colName TEXT, $colNote TEXT, $colAbout TEXT, $colTitle TEXT, $colEmail TEXT,$colBusinessName TEXT ,$colGroup TEXT , $colWebsite TEXT,  $colGlobalID TEXT, $colContactNos TEXT, $colSocialMedias TEXT, $colAddress text , $colCustomFields TEXT, $colDateTimeCreated TEXT,$colDateTimeUpdated TEXT, $colUpdateHistory TEXT, $colIsUpdated TEXT, $colFav TEXT, $colAuthentic Text , $colCardType TEXT, $colImageTokens TEXT,$coltemplateName TEXT, $colBusinessCode TEXT )"
        );
        await db.execute(
            "CREATE TABLE $myCardTable($colCardName TEXT PRIMARY KEY,$colName TEXT, $colAbout TEXT, $colTitle TEXT, $colEmail TEXT,$colBusinessName TEXT , $colWebsite TEXT,  $colGlobalID TEXT, $colContactNos TEXT, $colSocialMedias TEXT, $colAddress text , $colCustomFields TEXT, $colDateTimeCreated TEXT,$colDateTimeUpdated TEXT, $colUpdateHistory TEXT, $colIsUpdated TEXT, $colAuthentic Text , $colNickName TEXT, $colBusinessCode TEXT, $colIsAnalytics TEXT, $colIsSecureSharing TEXT , $colCardsLeft TEXT, $colCardType TEXT, $colImageTokens TEXT, $coltemplateName TEXT)"
        );
        await db.execute(
            "CREATE TABLE $businessDetailsTable(id TEXT PRIMARY KEY, $colName TEXT, $colAbout TEXT, $colEmail TEXT,$colBusinessName TEXT , $colWebsite TEXT, $colContactNos TEXT, $colSocialMedias TEXT, $colAddress text , $colCustomFields TEXT, $colDateTimeCreated TEXT,$colAuthentic Text , $colBusinessCode TEXT, $colLocalEditable TEXT )"
        );
        await db.execute(
            "CREATE TABLE $sharedPrefsTable(id INTEGER PRIMARY KEY autoincrement ,$colEmail TEXT, $colPassword TEXT, $colPendingUIDs TEXT, $colScreenGuide TEXT,$colSharingPreferences TEXT , $colThemeMode TEXT,  $colIsMinimal)"
        );

      });
    }
  }
  closeDb() async{
    if(_database!=null){
    await _database!.close();
    log("closed sql data base");
    } else {
      log("the data base is nutll");
    }
  }
  //delete
  Future deleteCardDatabase() async {
    await openDb();
    try {
      _database!.execute("delete from $cardTable");
    } catch (e) {
      log(e.toString());
    }
    try {
      _database!.execute("delete from $myCardTable");
    } catch (e) {
      log(e.toString());
    }
  }

  //add
  Future<CardData> myCards_addCard(CardData cardData) async {
    // unprocessed card as input
  final CardData card = cardData.clone();
    await openDb();
    log("adding my card in sql data base ${card.getMapFromCardData()}");
    //insert to local databases
    await _database!.insert(myCardTable, card.getMapFromCardData());
    log("inserted to $myCardTable table ${card.getMapFromCardData()}");
    return card;
  }
  // returns real values
  Future<Map<String, CardData>> myCards_getAllCards() async{
      await openDb();
      List< Map<String, dynamic>> list = await _database!.query(myCardTable);
      log(" --3 $list");
      Map<String, CardData> _map = {};
      try {
        list.forEach((cardMap) {
                CardData card = CardData(imageTokens: {CardFace.front: null,CardFace.back: null,CardFace.icon: null});
                card.getCardDataFromMap(cardMap);
                _map.addAll({card.cardName!:card});
              });
      } catch (e) {
        logger.e(e);
      }
      ////logger.e("mappp ${_map}");
      return _map;
    }
  Future myCards_updateCard(CardData card)async{
    // un processed card as input
    await openDb();
    final CardData cardData = card.clone();
    late Map<String, String?> cardMap;
    try {
      // making sure that the card is processed
      logger.i("${cardData.getMapFromCardData()}");
      cardMap = cardData.getMapFromCardData();
      // cardData.cardName = null;
      logger.i("sql is $cardMap");
      int i =  await _database!.update(myCardTable,cardMap,where: "$colGlobalID = ? ", whereArgs: [cardMap["globalId"]]);
      logger.i("my card updated sql $i ${cardData.globalId}");
    } catch (e) {
      logger.e("${cardData.getMapFromCardData()}$e");
    }
    return;
   }

}