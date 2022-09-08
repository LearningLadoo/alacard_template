import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' show post, get;
import 'package:alacard_template/constants.dart';
import 'package:alacard_template/database/cardData.dart';
import 'package:alacard_template/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseDataStorage {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _firebaseStoragePath = "https://firebasestorage.googleapis.com/v0/b/alacard-template.appspot.com/o";

  // get template names
 Future<List<Map>> getTemplateNames() async{
   List<Map> _maps = [];
   for (String i in ["jpg","svg"]) {
     try {
          await _firestore.collection("templates/yunHi/"+i).get().then((value){
            value.docs.forEach((element) {
              Map _m = {
                "type":i,
                "id":element.id,
                "tokens":element.data()["tokens"],
              };
              print(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
              _maps.add(_m);
            });
          });
        } catch (e) {
          print(e);
        }
   }
   return _maps;
 }
 Image ctd_getSampleTemplate(String templateSubPath,String token){
   return Image.network("$_firebaseStoragePath/${templateSubPath.replaceAll("/","%2F")}%2Fsample?alt=media&token="+token);
 }
  Future<bool> ctd_getTemplateDetails(CardData _card) async{
    try {
      CardData cardData = _card;
      if(cardData.templateName == null || cardData.templateName!["source"]==null)return false;
      String? _path = getTemplateSubPath(cardData: cardData);
      String? _localPath = getTemplateSubPath(cardData: cardData, forLocal: true);
      if(_path == null) {
        logger.e("template path is null!");
        return false;}
      log(_path);
      dynamic umhmm = await _firestore.doc(_path).get();
      if(umhmm.data()!=null){
        dynamic value = umhmm.data();
        log("tokens ${value!["tokens"]}");
        //get all the files and store in device
        await ctd_getTemplateFiles(localTempSubPath:_localPath!,tempSubPath: _path,tokens:value!["tokens"]);
      }else{
        logger.e("no template found!");
      }
    } catch (e) {
      logger.e(e);
    }
    return true;
  }
  Future<bool> ctd_getTemplateFiles({required String tempSubPath, required String localTempSubPath, required Map tokens,}) async{
    // step-1 get the config1 File (the json file for svg or jpg type cards)
    String templatePath= "$_firebaseStoragePath/${tempSubPath.replaceAll("/","%2F")}";//front?alt=media&token=8b813da8-1661-446b-9bea-a5ba01877777";
    tokens.forEach((key, value) {
      value.forEach((fileName,token) async{// config1,front,back
        //for url path
        String fileDownloadUrl = "$templatePath%2F$fileName?alt=media&token=$token";
        String localPath = getTemplateLocalPath(tempSubPath: localTempSubPath,key:key,fileName:fileName);
        log("localPath = $localPath , download url is $fileDownloadUrl");
        //save File in device
        if(localPath!=NO_IMAGE_FOUND){
          try {
            var response = await get(Uri.parse(fileDownloadUrl));
            File(localPath).writeAsBytesSync(response.bodyBytes);
          } catch (e) {
            logger.e(e);
          }
        }
      });
    });
    return true;
  }
}