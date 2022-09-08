import 'dart:developer';
import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/databaseHelper.dart';
import 'package:alacard_template/database/sharedPrefsOfUser.dart';
import 'package:alacard_template/database/sharingPreferences.dart';
import 'package:alacard_template/firebase_options.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/screens/fullScreenLoading.dart';
import 'package:alacard_template/screens/myCards/myCards.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class FirebaseAppInitialize extends StatefulWidget {
  @override
  _FirebaseAppInitializeState createState() => _FirebaseAppInitializeState();
}

class _FirebaseAppInitializeState extends State<FirebaseAppInitialize> {
  Future<bool> _initialization() async{
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   return await initializeVariables();

 }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization(),
        builder: (context,snapshot){
          if(snapshot.hasError){
            //todo handle errors
            return Center();
          }
          //logger.e("yoooo ${snapshot.connectionState}");
          if(snapshot.connectionState==ConnectionState.done||snapshot.data==true){
            // return myCards in this option
            return MyCards();
          }

          //logger.v("yo3");
          return FullScreenLoader();
        });
  }
  Future<bool> initializeVariables() async{
    log("already ran $p_initializationAlreadyRan");
    if(p_initializationAlreadyRan) {
      log("already ran it is");
      return false;
    }
    p_initializationAlreadyRan = true;
    bool temp = false;
    try {
      // this is a workaround to actually unfocus textboxes in manageCardDetails as whenever the keyboard was off the firebase initialize was running
      if(bc_currContext!=null && MediaQuery.of(bc_currContext!).viewInsets.bottom==0.0){
        log("kool top ${MediaQuery.of(bc_currContext!).viewInsets.bottom}");
        //dismiss keyboard
        FocusScope.of(bc_currContext!).unfocus();
      }
      ////
      // get all cards
      await DatabaseHelper(bc_mainContext).getAllCardsFromLocalDatabase();
      // get Shared prefs
      p_SharedPrefs = SharedPrefsOfUser(email: email,sharingPreferences: SharingPreferences());
      log("mission p_sharedPrefs - ${p_SharedPrefs.getMapFormSharedPrefs()}");
      // providers
      Provider.of<Variables>(bc_mainContext,listen: false).updateIsMinimal(p_SharedPrefs.isMinimal, doNotify: false);
      Provider.of<Variables>(bc_mainContext,listen: false).updateSharingPrefs(p_SharedPrefs.sharingPreferences!, doNotify:  false);
      Provider.of<Variables>(bc_mainContext,listen: false).updateTheme(p_SharedPrefs.themeMode,doNotify: true);
    } catch (e) {
      log("initialize error - ${e.toString()}");
    }
    return temp;
  }
}
