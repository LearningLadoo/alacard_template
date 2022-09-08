import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/firebaseDataStorage.dart';
import 'package:alacard_template/functions.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChooseTemplates extends StatefulWidget {
  const ChooseTemplates({Key? key}) : super(key: key);

  @override
  State<ChooseTemplates> createState() => _ChooseTemplatesState();
}

class _ChooseTemplatesState extends State<ChooseTemplates> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      color: themeData.scaffoldBackgroundColor,
      height: deviceHeight/2,
      width: deviceWidth,
      child: FutureBuilder(
        future: FirebaseDataStorage().getTemplateNames(),
        builder: (context,AsyncSnapshot snap){
          if(!snap.hasData){
            print("no data");
            return Center();
          } else {
            print("it has data ${snap.data}");
            // return a list of widgets
            return Container(
              child: ListView.builder(
                  itemCount: snap.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map _m = snap.data[index];
                    String tempSubPath = "templates/yunHi/${_m["type"]}/${_m["id"]}";
                    Image sampleImg = FirebaseDataStorage().ctd_getSampleTemplate(tempSubPath,_m["tokens"]["sample"]["image"]);
                    return GestureDetector(
                      onTap: (){
                        Map tokens = _m["tokens"];
                        tokens.remove("sample");
                        AlacardDialog(context,child: ShowTemplate(context,sampleImg,tempSubPath,tokens,"${_m["id"]}"));
                      },
                      child: Container(
                          height: large*3,
                          child: sampleImg),
                    );
                  }));
            }
          }
        ,
      ),
    );
  }
  Widget ShowTemplate(BuildContext context, Image sampleImg, String tempSubPath, Map<dynamic, dynamic> tokens, String templateCode){
    ThemeData themeData = Theme.of(context);
    return Container(
      color: themeData.scaffoldBackgroundColor,
      height: deviceHeight/2,
      width: deviceWidth,
      child: Column(
        children: [
          FittedBox(
            child: SizedBox(
              width: deviceWidth,
              child: sampleImg,
            ),
          ),
          // save and use
          ButtonType2(themeData: themeData, height: large, onPressed: () async{
            // enable the template in bg
            await FirebaseDataStorage().ctd_getTemplateFiles(tempSubPath: tempSubPath, localTempSubPath: "myTemplates/"+tempSubPath, tokens: tokens);
            p_imageAsTemplateCode = templateCode;
            Provider.of<Variables>(context, listen: false).updateAreImagesEdited(CardFace.front);
            int count = 0;
            Navigator.popUntil(context, (route) => count++ == 3);
          }, icon: Icons.check)
        ],
      ),
    );
  }
}
