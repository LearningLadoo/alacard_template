import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/firebaseDataStorage.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:alacard_template/utils/common/buttons.dart';
import 'package:alacard_template/utils/common/filterOptionChip.dart';
import 'package:alacard_template/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class ChooseTemplates extends StatelessWidget {
  const ChooseTemplates({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      // padding: EdgeInsets.all(small),
      height: deviceHeight*0.8,
      width: deviceWidth,
      child: Column(
        children: [
          Spacing().smallWiget,
          Spacing().smallWiget,
          Text("Choose Template",style: themeData.textTheme.headline1),
          FutureBuilder(
            future: FirebaseDataStorage().getTemplateNames(),
            builder: (context,AsyncSnapshot snap){
              if(!snap.hasData){
                print("no data");
                return SizedBox(
                    height: deviceHeight*0.5,
                    child: Center(child: Loader(large)));
              } else { return ChooseIt(map: snap.data); }
            }
            ,
          ),
        ],
      ),
    );;
  }
}

class ChooseIt extends StatefulWidget {
  List<Map> map;
  ChooseIt({required this.map});
  @override
  State<ChooseIt> createState() => _ChooseItState();
}

class _ChooseItState extends State<ChooseIt> {
  bool isTagOptionOpen = false;
  late Map<String,List<String>> _tags;
  late List<String> _tagsUsed;
  List<String> _tagsSelected = [];
  String selectedId = "";
  @override
  void initState() {
    _tags = widget.map.removeLast().cast();
    _tagsUsed = _tags.keys.toList();
    print(_tags);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      height: deviceHeight*0.8-2*small-medium*1.2,
      padding: EdgeInsets.all(small),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(small),
              child: GestureDetector(
                  onTap: (){
                    setState((){
                      isTagOptionOpen = !isTagOptionOpen;
                    });
                  },
                  child: Opacity(
                      opacity: 0.8,
                      child: Text("Tags ${isTagOptionOpen?"▲":"▼"}"))),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: small,right: small),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                curve: Curves.easeInOut,
                duration: Duration(milliseconds: 300),
                child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: small*0.5,
                    runSpacing: small*0.4,
                    children : (isTagOptionOpen?_tagsUsed:[]).map((tag){
                      return chip(
                          label: tag,
                          height: medium*1.4,
                          isSelected: _tagsSelected.contains(tag),
                          onChangedFn:  (isSelected){
                            setState(() {
                              if(_tagsSelected.contains(tag)){
                                print("remived it $_tagsSelected");
                                _tagsSelected.remove(tag);
                              }else {
                                print("selected it $_tagsSelected");
                                try {
                                  _tagsSelected.add(tag);
                                } catch (e) {
                                  print(e);
                                }
                              }
                            });
                          });
                    }).toList()
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
                padding: EdgeInsets.fromLTRB(0, small, 0, 0),
                child: Scrollbar(
                  child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(small,0.0,small,0.0),// for scroll bar
                    physics: BouncingScrollPhysics(),
                      itemCount: widget.map.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map _m = widget.map[index];
                        // checking if the tag is selected
                        if(_tagsSelected.isNotEmpty && !doesTagContainId(_m["id"],_tagsSelected,_tags)) return Center();
                        // returning the sample card image
                        String tempSubPath = "templates/yunHi/${_m["type"]}/${_m["id"]}";
                        print("hello $tempSubPath");
                        Image sampleImg = FirebaseDataStorage().ctd_getSampleTemplate(tempSubPath,_m["tokens"]["sample"]["image"]);
                        return GestureDetector(
                          onTap: (){
                            setState((){
                              selectedId = _m["id"];
                            });
                            // AlacardDialog(context,child: ShowTemplate(context,sampleImg,tempSubPath,tokens,"${_m["id"]}"));
                          },
                          child: Padding(
                            padding: EdgeInsets.only(bottom: small*2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                padding: EdgeInsets.all(small),
                                width: deviceWidth,
                                color: themeData.primaryColorDark,
                                // padding: EdgeInsets.all(small),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10.0),
                                        child: SizedBox(
                                          width: deviceWidth,
                                          child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: sampleImg),
                                        ),
                                      ),
                                      if(selectedId==_m["id"])Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Spacing().smallWiget,
                                          Text(
                                            "created by ${_m["createdBy"]}",
                                            style: TextStyle(
                                              color: themeData.textTheme.headline2!.color!.withOpacity(0.3),
                                              fontFamily: themeData.textTheme.headline2!.fontFamily,
                                              fontSize: themeData.textTheme.headline2!.fontSize!/20*10,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                          Spacing().tinyWidget,
                                          Text(
                                            "${_m["about"]}",
                                            style: themeData.textTheme.bodyText2,
                                            textAlign: TextAlign.left,
                                          ),
                                          Spacing().smallWiget,
                                          ButtonType3(
                                            height: medium*1.2,
                                            width: large,
                                            text: " Use ",
                                            offset: 0,
                                            themeData: themeData,
                                            isbnw: true,
                                            bgColor: themeData.colorScheme.onPrimary,
                                            onPressed: () async{
                                              // enable the template in bg
                                              Map tokens = _m["tokens"];
                                              tokens.remove("sample");
                                              await FirebaseDataStorage().ctd_getTemplateFiles(tempSubPath: tempSubPath, localTempSubPath: "myTemplates/"+tempSubPath, tokens: tokens);
                                              p_imageAsTemplateCode = _m["id"];
                                              Provider.of<Variables>(context, listen: false).updateAreImagesEdited(CardFace.front);
                                              int count = 0;
                                              Navigator.popUntil(context, (route) => count++ == 2);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                  ),
                            ),
                          ),
                        );
                      }),
                )),
          ),
          Spacing().smallWiget,
        ],
      ),
    );
  }
  bool doesTagContainId(String id, List<String> _tagsSelected, Map<String,List<String>> _tags){
    print("che - $id ans $_tagsSelected");
    for(String tag in _tagsSelected){
      print("checci - $tag ans $_tagsSelected");
      if(_tags[tag]!.contains(id))return true;
    }
    return false;
  }
  Widget ShowTemplate(BuildContext context, Image sampleImg, String tempSubPath, Map<dynamic, dynamic> tokens, String templateCode){
    ThemeData themeData = Theme.of(context);
    return Container(
      color: themeData.scaffoldBackgroundColor,
      height: deviceHeight,
      width: deviceWidth,
      child: Column(
        children: [
          SizedBox(
            width: deviceWidth,
            child: sampleImg,
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