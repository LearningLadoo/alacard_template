import 'package:flutter/material.dart';

class ImageShadow extends StatelessWidget {
  String? assetPath="";
  Color? color = Colors.transparent , shadowColor = Colors.black;
  double? width,height;
  ImageShadow({this.assetPath, this.color , this.height , this.width , this.shadowColor});

  Widget Sample(double marginLT){
    return Container(
      height: height,
      width: width,
      margin:EdgeInsets.fromLTRB(marginLT,marginLT,2,0),
      child: Image.asset(assetPath!,color: shadowColor!.withOpacity(0.1),),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: Stack(
        children: <Widget>[
          Sample(2.0),Sample(4.0),Sample(6.0),Sample(9.0),
          Center(child: Image.asset(assetPath!,color: color,))
        ],
      ),
    );

  }
}
