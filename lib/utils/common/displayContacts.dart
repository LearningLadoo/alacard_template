import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/database/cardFields/contactNo.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DisplayContacts extends StatelessWidget {
  /// provide card when crud is read otherwise it will give error
  late List<ContactNo> contactList;
  bool enabled;
  CRUD crud;
  CardData? card;
  DisplayContacts({this.enabled = true , this.crud = CRUD.update , this.card});
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    contactList = crud == CRUD.read?card!.contactNos??[]:(Provider.of<Variables>(context).tempCardDetails.contactNos??[]);
    return AbsorbPointer(
      absorbing: !enabled,
      child: Padding(
        padding: EdgeInsets.only(bottom: crud==CRUD.read&&contactList.length>0?small*1.3:0),
        child: EmbossBg(
            contactCardHeight * contactList.length,
            deviceWidth*0.9,
            depth: crud==CRUD.read?0:12,
            themeData: themeData,
            child:Column(
              children: [
                for(int i =0 ; i<contactList.length;i++)ContactCard(context,contactList, i, themeData , crud: crud)
              ],
            )
        ),
      ),
    );
  }
}
