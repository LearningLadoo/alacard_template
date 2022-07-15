import 'dart:async';
import 'dart:developer';
import 'package:alacard_template/constants.dart';
import 'package:alacard_template/screens/myCards/utils/myCardsList.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';

class MyCards extends StatefulWidget {
  @override
  _MyCardsState createState() => _MyCardsState();
}
class _MyCardsState extends State<MyCards> {
  bool willPop = true;
  int maxCardsAllowed = 20;
  int extraCards = 0;
  late int totalCards; // total cards is submission of maxCardsAllowed and extraCards (maybe aadhaar card in future)

  @override
  void initState() {

    totalCards = maxCardsAllowed+extraCards;

    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bc_currContext = context;
    ThemeData themeData = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        return willPop;
      },
      child: OnScreenLoader(
        themeData: themeData,
        child: Builder(
            builder: (context) {
              p_progressHud = ProgressHUD.of(context);
              return Scaffold(
                body: SizedBox(
                  height: deviceHeight,
                  width: deviceWidth,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: deviceStatusBarHeight),
                        child: SizedBox(
                          height: large-4,
                          child: Row(
                            children: [
                              ButtonType2(
                                themeData: Theme.of(context),
                                subText: "Go back",
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                height: large,
                                width: large,
                                icon: Icons.arrow_back_rounded,
                              ),
                              Expanded(child: Center())
                            ],
                          ),
                        ),
                      ),
                      Expanded(child: MyCardsList()),
                    ],
                  ),
                ),
              );
            }
        ),
      ),
    );
  }
}
