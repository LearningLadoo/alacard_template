import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/database/cardFields/customField.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DisplayCustomField extends StatelessWidget {
  late List<CustomField> customField;
  bool enabled;
  CRUD crud;
  CardData? card;
  DisplayCustomField({this.enabled = true , this.crud = CRUD.update , this.card});
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    customField = crud == CRUD.read?card!.customFields??[]:(Provider.of<Variables>(context).tempCardDetails.customFields??[]);
    return AbsorbPointer(
      absorbing: !enabled,
      child: Padding(
        padding: EdgeInsets.only(bottom: crud==CRUD.read&&customField.length>0?small*1.3:0),
        child: EmbossBg(
            socialCardHeight * customField.length,
            deviceWidth*0.9,
            themeData: themeData,
            depth: crud==CRUD.read?0:12,
            child:Column(
              children: [
                for(int i =0 ; i<customField.length;i++)CustomFieldCard(context,customField, i, themeData , crud: crud)
              ],
            )
        ),
      ),
    );
  }
}
