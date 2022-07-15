import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/database/cardFields/socialMedia.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DisplaySocial extends StatelessWidget {
  late List<SocialMedia> socialList;
  bool enabled;
  CRUD crud;
  CardData? card;
  DisplaySocial({this.enabled = true , this.crud = CRUD.update , this.card});
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    socialList = crud==CRUD.read?card!.socialMedias??[]:(Provider.of<Variables>(context).tempCardDetails.socialMedias??[]);
    return AbsorbPointer(
      absorbing: !enabled,
      child: Padding(
        padding: EdgeInsets.only(bottom: crud==CRUD.read&&socialList.length>0?small*1.3:0),
        child: EmbossBg(
            socialCardHeight * socialList.length,
            deviceWidth*0.9,
            themeData: themeData,
            depth: crud==CRUD.read?0:12,
            child:Column(
              children: [
                for(int i =0 ; i<socialList.length;i++)SocialCard(context,socialList, i, themeData , crud:crud)
              ],
            )
        ),
      ),
    );
  }
}
