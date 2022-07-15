import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/database/databaseHelper.dart';
import 'package:alacard_template/database/sharingPreferences.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/providers/cardsMapProvider.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/screens/manageCardDetails/manageCardDetails.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCardsList extends StatefulWidget {
  String? selectedMyCard; // if we have to choose a card
  MyCardsList({this.selectedMyCard});
  @override
  _MyCardsListState createState() => _MyCardsListState();
}

class _MyCardsListState extends State<MyCardsList> {
  String? defaultSelectedCardName,tappedCardName;
  Map<String,CardData> myCardsMap  = {};
  late SharingPreferences sharingp;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    setState(() {
      sharingp = Provider.of<Variables>(context).sharingPrefs;
      logger.i("yumm ${sharingp.sharingPreferencesToString()}");
      defaultSelectedCardName = (widget.selectedMyCard!=null)?widget.selectedMyCard!:sharingp.defaultCardName;
      myCardsMap = Provider.of<CardsMapProvider>(context).userCardsMap;
      });
    List<Container> children = [
      // Container(child: RealTimeMessage(tag: "topMyCardsMessage",)),
      if(!(widget.selectedMyCard!=null))Container(
        width: deviceWidth,
        padding: EdgeInsets.fromLTRB(small, 0, small, tiny),
        child: Text(email,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: themeData.textTheme.headline2!.color!.withOpacity(0.5),
              fontFamily: themeData.textTheme.headline2!.fontFamily,
              fontWeight: FontWeight.normal,
              fontSize: themeData.textTheme.headline6!.fontSize,)),
      ),];
    children.addAll(quickSort(myCardsMap.values.toList(),0, myCardsMap.length-1).map((entry){
      String cardName = entry.cardName!;
      CardData myCard = entry;
      return Container(
        margin: EdgeInsets.only(top : small ),
        child: ElevatedBg(
          small*7,
          deviceWidth-((widget.selectedMyCard!=null)?4:2)*small,
          themeData,
          offset: tappedCardName==cardName?0:null,
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTapDown: (_){
              setState(() {
                tappedCardName = cardName;
              });
            },
            onTapCancel: (){
              setState(() {
                tappedCardName = null;
              });
            },
            onTap: (){
              if(!(widget.selectedMyCard!=null)){
                setState(() {
                  tappedCardName = null;
                });
                Navigator.push(context, MaterialPageRoute(builder:(context) => ManageCardDetails(crud: CRUD.update,index: cardName,) ));}
              else{
                // p_SharedPrefs.sharingPreferences!.defaultCardName = cardName;
                defaultSelectedCardName = cardName;
                sharingp.defaultCardName = cardName;
                logger.i("the cardName is $cardName");
                // updating provider
                Provider.of<Variables>(context,listen:false).updateSharingPrefs(sharingp);
                Navigator.pop(context);
              }
            },
            child: Row(
              children: [
                //card nick name and cards left
                Expanded(
                  child: Padding(
                    padding:EdgeInsets.all(small),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            myCard.nickName??((myCard.name==null||myCard.name=="")?"My Card ${getNumberFromName(myCard.cardName??"0")}":myCard.name!),
                            style: themeData.textTheme.headline2,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                        ),
                        Opacity(
                          opacity: 0.8,
                          child: Text(
                            "shares left : ${myCard.cardsLeft??"NA"}",
                            style: themeData.textTheme.subtitle1,),
                        ),
                      ],
                    ),
                  ),
                ),
                // todo authenticated animation
                //settings
                if(!(widget.selectedMyCard!=null))
                  ButtonType2(
                    themeData: themeData,
                    subText: "Settings",
                    height: large,
                    width: large,
                    icon: Icons.settings_rounded,
                    onPressed:(){
                      // Navigator.push(context, MaterialPageRoute(builder:(context) => MyCardSettings(myCard) ));
                    },
                  ),
                //selected
                if(myCardsMap.length>1)ButtonType2(
                  isActivated: cardName==defaultSelectedCardName,
                  themeData: themeData,
                  subText: (widget.selectedMyCard!=null)?"select":"select \nas default   ",
                  height: large,
                  width: large,
                  icon: Icons.circle,
                  onPressed:(){
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }).toList());
    children.add(Container(height: large,));
    return (widget.selectedMyCard!=null)?
    Column(children: children)
    :Stack(
      children: [
        SizedBox(
            height: deviceHeight-large*2,
            width: deviceWidth,
            child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                    children: children))),
        // Expanded(child: Center()),
        Positioned(
          bottom: 0,
          child: Center(
            child: Container(
              width: deviceWidth,
              color: themeData.scaffoldBackgroundColor,
              padding: EdgeInsets.fromLTRB(small,tiny,small,small),
              child: ButtonType3(
                height: medium*1.8,
                width: deviceWidth-medium,
                onPressed: () async{
                  Map<String,CardData> myCardsMap = Provider.of<CardsMapProvider>(context,listen: false).userCardsMap;
                  await DatabaseHelper(context).setupNewMyCard(myCardsMap.length+1);
                },
                themeData: themeData,
                text: "Add New Card",
                bgColor:getAdjustColor(themeData.iconTheme.color!,20),
                isbnw: true,
              ),
            ),
          ),
        ),

      ],
    );
  }
}
Widget sampleMyCard(ThemeData themeData){
  return Padding(
    padding: EdgeInsets.only(top : small ),
    child: ElevatedBg(
      small*7,
      deviceWidth-2*small,
      themeData,
      child: Row(
        children: [
          //card nick name and cards left
          Padding(
            padding:EdgeInsets.all(small),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    "My Card 1",
                    style: themeData.textTheme.headline2),
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    "shares left : 10",
                    style: themeData.textTheme.subtitle1,),
                ),
              ],
            ),
          ),
          Expanded(child: Center()),
          //settings
          ButtonType2(
            themeData: themeData,
            subText: "Settings",
            height: large,
            width: large,
            icon: Icons.settings_rounded,
            onPressed:(){},
          ),
          //selected
          ButtonType2(
            isActivated: true,
            themeData: themeData,
            subText: "select \nas default   ",
            height: large,
            width: large,
            icon: Icons.circle,
            onPressed:(){},
          ),
        ],
      ),
    ),
  );
}