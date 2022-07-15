import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/database/databaseHelper.dart';
import 'package:alacard_template/providers/cardsMapProvider.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/common/textField.dart';
import 'package:alacard_template/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageNote extends StatefulWidget {
  /// crud values
  /// read = editable but directly without edit
  /// update = editable for manually added cards
  CRUD crud;
  CardData? card;
  ManageNote({this.crud=CRUD.update, this.card});
  @override
  _ManageNoteState createState() => _ManageNoteState();
}

class _ManageNoteState extends State<ManageNote> {
  String note = "";
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    String preText = "";
    bool minimal = false;
    if(widget.crud==CRUD.read){
      preText = widget.card!.note??"";
    } else {
      minimal = Provider.of<Variables>(context, listen: false).isMinimal;
      preText = Provider.of<Variables>(context, listen: false).tempCardDetails.note??"";
    }
    logger.i("pre note is $preText");
    return Container(
      height: 25*small,
      width: deviceWidth - large,
      decoration: BoxDecoration(
        color: themeData.backgroundColor,
        borderRadius: BorderRadius.circular(small),
      ),
      child: Column(
        children: [
          Spacing().smallWiget,
          Text("Note",style: themeData.textTheme.headline1,),
          Spacing().mediumWidget,
          EmbossedTextField(
              text: (minimal?"Enter note":"Use note to easily find this card"),
              initialValue: preText,
              lines: 5,
              height: (4+5*2)*small,
              themeData: themeData,
              width: deviceWidth*0.8,
              textInputAction: TextInputAction.done,
              onEditingComplete: (value){
                if(value!=null){
                  note = value;
                  addTheNewNote();
                }
              },
              onChangedFn: (value){
                if(value!=null){
                  setState(() {
                    note = value;
                  });
                }
              },
              validatorFn: (value){}),
          ButtonType3(
            height: medium*1.2,
            width: large*2.2,
            text: (preText=="")?" Add ":" Save ",
            offset: 0,
            themeData: themeData,
            isbnw: true,
            bgColor: themeData.colorScheme.onPrimary,
            onPressed: () async {
              addTheNewNote();
            },
          ),
        ],
      ),
    );
  }
  addTheNewNote(){
    // save the temp card Provider with new data
    logger.i("the note is = $note");
    if(widget.crud!=CRUD.read) {
      Provider.of<Variables>(context, listen: false).editTempCardNote(note);
    } else {
      widget.card!.note = note;
      DatabaseHelper(context).updateCard(widget.card!);
    }
    Navigator.pop(bc_alacardDialogContext);
  }
}
