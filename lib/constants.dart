import 'dart:ui' as UI;
import 'package:alacard_template/assets/social_icons_icons.dart';
import 'package:alacard_template/database/sharedPrefsOfUser.dart';
import 'package:alacard_template/database/sqlManager.dart';
import 'package:alacard_template/functions.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

//routes
const String
    r_mycards = "/myCards",
    r_manageCards = "/manageCards",
    r_initialize = "/FirebaseInitialize",
    r_fullScreenLoader = "/FullScreenLoad";


late BuildContext bc_mainContext;
BuildContext? bc_manageCardContext;
BuildContext? bc_currContext;
late BuildContext bc_alacardDialogContext;
late BuildContext bc_showCardContext;

SqlManager p_sqlManager = SqlManager();
String? p_imageAsTemplateCode; // this contains the code for image as a template type, this is initialized when the checkbox is made true and when use an inbuilt template is clicked (in-jpg-1)
late dynamic p_progressHud; // dashboard, received card handeler,
int p_cardsToBeAdded = 0;
int p_cardsAdded = 0;
List<String> p_tempDomains = [];
bool p_initializationAlreadyRan = false;
GlobalKey bgKey = GlobalKey();
String email = "testemail@gmail.com";
String uid = "tempGlobalIdhaiye";
String version = "v 1.0.4+5";
String iconsDir = "assets/icons";
String lottieDir = "assets/lotties";
String welcomeBack = "It feels so good to see you back :)";
String registerProperly ="Make sure you enter a valid Email and create a password longer than 7 digits";
String pleaseConnectToInternet = "Please connect to Internet :(";
const String defaultCountryCode = "+91";
const String sameFieldSeparator = "|",typeSeparator = "^", propertiesSeparator = "#", unfinished = "~";
const String NO_IMAGE_FOUND = "noImage";
const String NOT_FOUND = "notFound";
bool willCloseSql = true;
ThemeMode? themeMode;
enum UiModes { dark, light, auto }
enum NavigateTypes { push, pushReplacement }
enum CardType { mine, received, manuallyAdded }
enum CardFace { front, back, icon }
enum CRUD { create, read, update, delete }
enum Filter {none,name,note,about,title,email,businessName,website,contactNos,socialMedias,address,customFields}
enum ShareMode{link,qr}
enum ServiceActions{setAsForeground,setAsBackground,stopService,backupMyCards,updateProviderFromSql}

List<String> infoType = ["Text","Link","Date","Address","Email"];
List<String> contactType = ["Work", "Personal", "WhatsApp", "Other"];
List<String> socialType = [
  "AngelList",
  "Behance",
  "BlogSpot",
  "Digg",
  "Discord",
  "Dribbble",
  "EarlyBirds",
  "Facebook",
  "Flickr",
  "GitHub",
  "Instagram",
  "Kaggle",
  "LinkedIn",
  "Medium",
  "Odnoklassniki",
  "Patreon",
  "Pinterest",
  "Quora",
  "Reddit",
  "Scribd",
  "Slideshare",
  "Snapchat",
  "Spotify",
  "Stack Overflow",
  "Telegram",
  "Tumblr",
  "Twitch",
  "Twitter",
  "Vimeo",
  "Vk",
  "Wikipedia",
  "YouTube",
  "Other"
];
Map<String, List<dynamic>> socialTypeDetails = {
  //replace _ with username and if no _ then link field is not visible
  "AngelList": ["angel.co/p/_", SocialIcons.angellist],
  "Behance": ["behance.net/_", SocialIcons.behance],
  "BlogSpot": ["_.blogspot.com", SocialIcons.blogger_b],
  "Digg": ["digg.com/@_", SocialIcons.digg],
  "Discord": ["discord.com/channels/@me", SocialIcons.discord],
  "Dribbble": ["dribbble.com/_", SocialIcons.dribbble],
  "EarlyBirds": ["earlybirds.io/en/_", SocialIcons.earlybirds],
  "Facebook": ["facebook.com/_", SocialIcons.facebook_f],
  "Flickr": ["flickr.com/people/_", SocialIcons.flickr],
  "GitHub": ["github.com/_", SocialIcons.github],
  "Instagram": ["instagram.com/_", SocialIcons.instagram],
  "Kaggle": ["kaggle.com/_", SocialIcons.kaggle],
  // "Line":["xxxx",SocialIcons.line],
  "LinkedIn": ["linkedin.com/in/_", SocialIcons.linkedin_in],
  "Medium": ["medium.com/@_", SocialIcons.medium_m],
  "Odnoklassniki": ["ok.ru/_", SocialIcons.odnoklassniki],
  "Patreon": ["patreon.com/_", SocialIcons.patreon],
  "Pinterest": ["pinterest.com/_", SocialIcons.pinterest_p],
  "Quora": ["quora.com/profile/_", SocialIcons.quora],
  "Reddit": ["reddit.com/user/_", SocialIcons.reddit_alien],
  "Scribd": ["scribd.com/author/_", SocialIcons.scribd],
  "Slideshare": ["slideshare.net/_", SocialIcons.slideshare],
  "Snapchat": ["snapchat.com/add/_", SocialIcons.snapchat_ghost],
  "Spotify": ["open.spotify.com/artist/_", SocialIcons.spotify],
  "Stack Overflow": ["stackoverflow.com/users/_", SocialIcons.stack_overflow],
  "Telegram": ["t.me/_", SocialIcons.telegram_plane],
  "Tumblr": ["tumblr.com/blog/view/_", SocialIcons.tumblr],
  "Twitch": ["twitch.tv/_", SocialIcons.twitch],
  "Twitter": ["twitter.com/_", SocialIcons.twitter],
  "Vimeo": ["vimeo.com/_", SocialIcons.vimeo_v],
  "Vk": ["vk.com/_", SocialIcons.vk],
  // "WeChat": ["vk.com/_", SocialIcons.wechat],
  "Wikipedia": ["en.wikipedia.org/wiki/_", SocialIcons.wikipedia_w],
  "WhatsApp": ["en.wikipedia.org/wiki/_", SocialIcons.whatsapp],
  "YouTube": ["vk.com/_", SocialIcons.youtube],

};
// Map<String, List>? ;
ImageProvider? p_testImage;
String? localPath;
UI.Image? p_templateImage ; // this is used to provide the image to convert to final card
Map<String,dynamic> p_templateMap = {}; // this handles the structure and style of font on card
SharedPrefsOfUser p_SharedPrefs = SharedPrefsOfUser(); // similar as prefs saved in sql
GlobalKey? frontKey ;
GlobalKey? backKey ;

double? p_textScale_ratio;
double p_textLimit_Ratio = 1.0;
double tiny = 5*p_textScale_ratio!,
    small = 10*p_textScale_ratio!,
    medium = 25*p_textScale_ratio!,
    large = 50*p_textScale_ratio!,
    deviceStatusBarHeight = statusBarHeight(bc_mainContext),
    deviceHeight = screenHeight(bc_mainContext),
    deviceWidth = screenWidth(bc_mainContext);
    double contactCardHeight = large ,  socialCardHeight = large;
class Spacing {
  SizedBox tinyWidget = SizedBox(
        height: tiny,
      ),
      smallWiget = SizedBox(
        height: small,
      ),
      mediumWidget = SizedBox(
        height: medium,
      ),
      largeWidget = SizedBox(
        height: large,
      ),
      statusBarSizedWidget = SizedBox(
        height: deviceStatusBarHeight,
      );
}
Logger logger = Logger(
  printer: PrettyPrinter()
);


///Themes
//Light theme
final ThemeData lightTheme = ThemeData(
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: const Color(0xFFf48e95).withOpacity(0.6),
        // cursorColor: const Color(0xFFf0538a).withOpacity(0.3),
        selectionColor: Colors.white.withOpacity(0.3)),
    errorColor: const Color(0xFFea5959).withOpacity(0.8),
    //for wrong
    focusColor: Color(0xFF37b05c).withOpacity(1),
    //for right
    primaryColorDark: Colors.white,
    shadowColor: Color.fromRGBO(240, 240, 240, 1.0),
    backgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
    scaffoldBackgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
    canvasColor: Color.fromRGBO(240, 240, 240, 1.0),
    appBarTheme: AppBarTheme(
      toolbarTextStyle: TextStyle(
        color: Color(0xFF3d516d).withOpacity(0.8),
        fontSize: 20.0,
      ),
      color: Color.fromRGBO(240, 240, 240, 1.0),
      iconTheme: IconThemeData(
        color: Color(0xFF3d516d).withOpacity(0.8),
      ),
    ),
    colorScheme: ColorScheme.light(
      //fb2779
      primary: const Color(0xFFdb4c77).withOpacity(1),
      onPrimary: const Color(0xFFdb4c77).withOpacity(0.8),
      // primary: const Color(0xFFF06992),
      // onPrimary : const Color(0xFFf0538a).withOpacity(0.9),
      primaryVariant: Colors.white38,
      secondary: Color(0xFF24334a),
    ),
    cardTheme: CardTheme(
      color: Colors.teal,
    ),
    iconTheme: IconThemeData(
      color: Color(0xFF3d516d).withOpacity(0.6),
    ),
    textTheme: TextTheme(
      // main headlines like Dashboard, Settings etc
      headline1: TextStyle(
          fontFamily: "Raleway",
          color: Color(0xFF3d516d).withOpacity(0.8),
          fontSize: 25.0*p_textLimit_Ratio,
          fontWeight: FontWeight.w600,
          letterSpacing: 3
      ),
      headline2: TextStyle(
          color: const Color(0xFF3d516d).withOpacity(0.8),
          fontFamily: "OpenSans",
          fontSize: 20.0*p_textLimit_Ratio,
          letterSpacing: 1),
      headline3: TextStyle(
        fontFamily: "OpenSans",
        color: const Color(0xFF3d516d).withOpacity(0.8),
        fontSize: 18.0*p_textLimit_Ratio,
        fontWeight: FontWeight.bold,
      ),
      headline4: TextStyle(
        color: const Color(0xFF3d516d).withOpacity(0.8),
        fontFamily: "OpenSans",
        fontSize: 18.0*p_textLimit_Ratio,
      ),
      headline5: TextStyle(
        color: Color(0xFFdb4c77).withOpacity(0.8),
        fontFamily: "OpenSans",
        fontSize: 50.0*p_textLimit_Ratio,
      ),
      headline6: TextStyle(
        fontFamily: "OpenSans",
        color: Colors.black45,
        fontSize: 15.0*p_textLimit_Ratio,
      ),
      subtitle1: TextStyle(
        color: const Color(0xFF3d516d).withOpacity(0.8),
        fontFamily: "OpenSans",
        fontSize: 15.0*p_textLimit_Ratio,
      ),
      subtitle2: TextStyle(
        color: const Color(0xFFdb4c77).withOpacity(0.7),
        fontFamily: "OpenSans",
        fontSize: 16.0*p_textLimit_Ratio,
      ),
      bodyText1: TextStyle(
        color: const Color(0xFFdb4c77).withOpacity(0.7),
        fontFamily: "OpenSans",
        fontSize: 14.0*p_textLimit_Ratio,
      ),
      bodyText2: TextStyle(
        color: const Color(0xFF3d516d).withOpacity(0.75),
        fontFamily: "OpenSans",
        fontSize: 12.0*p_textLimit_Ratio,
      ),
    ),
    dividerTheme: DividerThemeData(thickness: 0.9, color: Colors.black12));
//Dark theme
final ThemeData darkTheme = ThemeData(
    backgroundColor:Color(0xFF2b394e) ,
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: const Color(0xFFf48e95).withOpacity(0.3),
        selectionColor: Colors.white.withOpacity(0.3)),
    primaryColorDark: Color(0xFF24334a),
    primaryColor: const Color(0xFFf0538a).withOpacity(0.7) ,
    shadowColor: Color(0xFF2b394e),
    errorColor: const Color(0xFFea5959).withOpacity(0.7),
    //for wrong
    focusColor: Color(0xFF04aa6b),
    //for right
    scaffoldBackgroundColor: Color(0xFF2b394e),
    canvasColor: Color(0xFF2b394e),
    appBarTheme: AppBarTheme(
      color: Color(0xFF2b394e),
      iconTheme: IconThemeData(
        color: Colors.white54,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFFff3f89),
      onPrimary: const Color(0xFFf0538a).withOpacity(0.9),
      primaryVariant: Colors.transparent,
      secondary: Colors.transparent,
    ),
    iconTheme: IconThemeData(
      color: Color(0xffa8afb9),
    ),
    textTheme: TextTheme(
      // main headlines like Dashboard, Settings etc
      headline1: TextStyle(
          fontFamily: "Raleway",
          color: Colors.white.withOpacity(0.6),
          fontSize: 25.0*p_textLimit_Ratio,
          fontWeight: FontWeight.w600,
          letterSpacing: 3
      ),
      // cardName basically
      headline2: TextStyle(
          fontFamily: "OpenSans",
          color: Colors.white70,
          fontSize: 20.0*p_textLimit_Ratio,
          letterSpacing: 1
      ),
      //button font,selectedItemTextStyle
      headline3: TextStyle(
        fontFamily: "OpenSans",
        color: Colors.white.withOpacity(0.7),
        fontSize: 18.0*p_textLimit_Ratio,
        fontWeight: FontWeight.bold,
      ),
      //option tile, share one way,dropDownListTextStyle, Embosstextfield text
      headline4: TextStyle(
        fontFamily: "OpenSans",
        color: Colors.white.withOpacity(0.7),
        fontSize: 18.0*p_textLimit_Ratio,
      ),
      headline5: TextStyle(
        fontFamily: "OpenSans",
        color: Color(0xFFff3f89).withOpacity(0.8),
        fontSize: 50.0*p_textLimit_Ratio,
      ),
      headline6: TextStyle(
        fontFamily: "OpenSans",
        color: Colors.black45,
        fontSize: 15.0*p_textLimit_Ratio,
      ),
      // cards left, email
      subtitle1: TextStyle(
        fontFamily: "OpenSans",
        color: Colors.white70,
        fontSize: 15.0*p_textLimit_Ratio,
      ),
      subtitle2: TextStyle(
        // Embosstextfield label, sample
        fontFamily: "OpenSans",
        color: const Color(0xFFff3f89).withOpacity(0.6),
        fontSize: 16.0*p_textLimit_Ratio,
      ),
      //filterchip,skip to home wali line
      bodyText1: TextStyle(
        color: const Color(0xFFff3f89).withOpacity(0.6),
        fontFamily: "OpenSans",
        fontSize: 14.0*p_textLimit_Ratio,
      ),
      bodyText2: TextStyle(
        color: Colors.white70,
        fontFamily: "OpenSans",
        fontSize: 12.0*p_textLimit_Ratio,
      ),
    ),
    dividerTheme: DividerThemeData(thickness: 0.9, color: Colors.black12));