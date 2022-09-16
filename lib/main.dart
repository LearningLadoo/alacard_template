import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/providers/cardsMapProvider.dart';
import 'package:alacard_template/providers/templateData.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/screens/fullScreenLoading.dart';
import 'package:alacard_template/screens/manageCardDetails/manageCardDetails.dart';
import 'package:alacard_template/utils/initialize/firebaseInitialize.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome, rootBundle;
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'constants.dart';

void main() async {
  // debugPaintSizeEnabled=true;
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(
          MultiProvider(
          providers: [
            ChangeNotifierProvider<Variables>(
              create: (context) => Variables(),
            ),
            ChangeNotifierProvider<CardsMapProvider>(
              create: (context) => CardsMapProvider(),
            ),
            ChangeNotifierProvider<TemplateData>(
              create: (context) => TemplateData(),
            ),
          ],
          child: OverlaySupport.global(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: MainApp(),
            ),
          ),
      ),
  );
}

class MainApp extends StatelessWidget {

  Future setupInitialVariables(BuildContext context)async{
    p_textScale_ratio = MediaQuery.of(context).textScaleFactor;
    log("keys - $p_textScale_ratio");
    if(p_textScale_ratio!>1.0){
      p_textLimit_Ratio = 1.0/p_textScale_ratio!;
      p_textScale_ratio = 1.0;
    }
    gettingLocalPath();
    bc_mainContext = context;
  }
  @override
  Widget build(BuildContext context) {
    setupInitialVariables(context);
    UiModes? modeEnum = Provider.of<Variables>(context).uiMode;
    print("i got it ${modeEnum.toString()}");
    switch (modeEnum) {
      case UiModes.light:
        themeMode = ThemeMode.light;
        break;
      case UiModes.dark:
        themeMode = ThemeMode.dark;
        break;
      case UiModes.auto:
        themeMode = ThemeMode.system;
        break;
      default:
        themeMode = ThemeMode.system;
    }
    // themeMode = ThemeMode.light;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alacard',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      initialRoute: r_initialize,
      onGenerateRoute: (settings) {
      switch (settings.name) { 
        case r_manageCards: return PageTransition(child: ManageCardDetails(), type: PageTransitionType.fade,curve: Curves.easeInOut,duration: Duration(milliseconds: 200),reverseDuration: Duration(milliseconds: 200));
        default: return null;
      }
    },
      routes: {
        r_initialize:(context)=>FirebaseAppInitialize(),
        r_fullScreenLoader:(context)=>FullScreenLoader(),
      },
      // this removes the scroll glow from the app
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child!,
        );
      },
    );
  }
}
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}