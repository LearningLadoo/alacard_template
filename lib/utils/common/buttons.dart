import 'package:alacard_template/constants.dart';
import 'package:alacard_template/providers/variables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


//thene button gives full raised neumorphic feel
class ButtonType1 extends StatefulWidget {
  String text;
  ThemeData themeData;
  Function onPressed;
  Function? onSelectButton;
  double height, width;
  double? offset;
  TextStyle? textStyle;
  bool enabled , isSelected;
  ButtonType1(
      {required this.text,
      required this.height,
      required this.themeData,
      required this.onPressed,
      required this.width,
      this.textStyle,
      this.offset,
      this.enabled = true,
      this.isSelected = false,
      this.onSelectButton});

  @override
  _ButtonType1State createState() => _ButtonType1State();
}

class _ButtonType1State extends State<ButtonType1> {
  late String text;
  late ThemeData themeData;
  late Function onPressed;
  late double height, width;
  late double offset;

  late Color color;

  Color? darkColor;
  Color? lightColor;
  Gradient? gradient;

  late List<BoxShadow> shadowList;
  bool _isPressed = false , _isSelected = false;
  TextStyle? textStyle;
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    themeData = widget.themeData;
    // deciding _themeMode as light or dark
    _themeMode = themeData.backgroundColor==Color(0xFF2b394e)?ThemeMode.dark:ThemeMode.light;
    text = widget.text;
    onPressed = widget.onPressed;
    height = widget.height;
    width = widget.width;
    textStyle = widget.textStyle;
    offset = widget.offset ?? 8;
    color = themeData.primaryColorDark;
    darkColor = _getAdjustColor(
        color, -offset * (_themeMode == ThemeMode.light ? 2 : 1));
    lightColor = _getAdjustColor(color, offset);
    _isSelected = widget.isSelected;

    if(!widget.enabled)_tapDown();

    gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [darkColor!, (_isPressed) ? darkColor! : lightColor!],
    );
    shadowList = [
      BoxShadow(
        color: lightColor!,
        offset: Offset(-offset * 0.3, -offset * 0.3),
        blurRadius: offset,
      ),
      BoxShadow(
        color: (_isPressed) ? lightColor! : darkColor!,
        offset: Offset(offset * 0.8, offset * 0.8),
        blurRadius: offset,
      ),
    ];
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: !(widget.enabled),
          child: GestureDetector(
            onTapDown: (_) => _tapDown(),
            onTapUp: (_) => _tapUp(),
            onTapCancel: _tapUp,
            onTap: onPressed as void Function()?,
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              height: height,
              width: width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: gradient,
                  boxShadow: shadowList),
              child: Center(
                  child: Text(
                text,
                style: textStyle ??
                    TextStyle(
                      fontFamily: themeData.textTheme.headline5!.fontFamily,
                      color: themeData.textTheme.headline5!.color!.withOpacity(0.7),
                      fontSize: themeData.textTheme.headline4!.fontSize
                    ),
              )),
            ),
          ),
        ),
        if(widget.onSelectButton!=null)
          Positioned(
            right: 0,
            top: 0,
            child: ButtonType2(
              isActivated: _isSelected,
              themeData: themeData,
              subText: "Add on card",
              onPressed: () {
                setState(() {
                  _isSelected=!_isSelected;
                });
                widget.onSelectButton!(_isSelected);
              },
              height: 3*small,
              width: 3*small,
              icon: Icons.call_made_rounded,
            ),
          ),
      ],
    );
  }

  Color _getAdjustColor(Color baseColor, double amount) {
    Map<String, int> colors = {
      'r': baseColor.red,
      'g': baseColor.green,
      'b': baseColor.blue
    };

    colors = colors.map((key, value) {
      if (value + amount < 0) {
        return MapEntry(key, 0);
      }
      if (value + amount > 255) {
        return MapEntry(key, 255);
      }
      return MapEntry(key, (value + amount).floor());
    });
    return Color.fromRGBO(colors['r']!, colors['g']!, colors['b']!, 1);
  }

  void _toggle(bool value) {
    if (_isPressed != value) {
      setState(() {
        _isPressed = value;
      });
    }
  }

  void _tapDown() => _toggle(true);

  void _tapUp() => _toggle(false);
}

//used for all small icons like back, menu, add etc
class ButtonType2 extends StatefulWidget {
  String? subText;
  TextAlign? subTextAlign;
  ThemeData themeData;
  Function onPressed;
  Function? onLongPressed;
  double height;
  double? width,fontSize; // if font size is given then width of parent widget is mage null thus fitted box makes the width accordingly
  Color? onClickColor;
  IconData icon;
  bool? isActivated;
  double? maxWidth;

  ButtonType2(
      {required this.themeData,
      this.subText,
      this.subTextAlign,
      required this.height,
      required this.onPressed,
      this.onLongPressed,
      this.width,
      this.maxWidth,
      this.fontSize,
      required this.icon,
      this.onClickColor,
      this.isActivated});

  @override
  _ButtonType2State createState() => _ButtonType2State();
}

class _ButtonType2State extends State<ButtonType2> {
  late ThemeData themeData;
  late Function onPressed;
  late double height, width;
  double? maxWidth, fontSize;
  late Color color, onClickColor;
  late IconData icon;
  bool? isClicked = false;
  bool? isActivate = false;
  bool minimal = false;
  @override
  void initState() {
    themeData = widget.themeData;
    onPressed = widget.onPressed;
    height = widget.height;
    width = widget.width ?? deviceWidth / 5;
    maxWidth = widget.maxWidth;
    onClickColor = widget.onClickColor ?? themeData.colorScheme.primary;
    icon = widget.icon;
    fontSize = widget.fontSize;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UiModes? modeEnum = Provider.of<Variables>(context).uiMode;
    switch (modeEnum) {
      case UiModes.light:
        themeData = lightTheme;
        break;
      case UiModes.dark:
        themeData = darkTheme;
        break;
      default:
    }
    setState(() {
      minimal = Provider.of<Variables>(context).isMinimal;
      if(!minimal&&!(widget.subText != null&&widget.subText != ""))minimal = true;
      isActivate = widget.isActivated;
      if (isActivate != null) {
        isClicked = isActivate;
      } else {
        isActivate = false;
      }
      height = widget.height;
      width = widget.width ?? deviceWidth / 5;
    });
    return InkResponse(
      highlightColor: Colors.transparent,
      radius: medium,
      onTapDown: (_) => _tapDown(),
      onTapCancel: _tapUp,
      onTap: () {
        _tapUp();
        onPressed();
      },
      onLongPress: (){
        if(widget.onLongPressed!=null) {
          widget.onLongPressed!();
        }
      },
      child: Container(
        height: !minimal ? height : (height - small),
        width:fontSize!=null?null:(!minimal ? (maxWidth??width*1.2):width),
        child: Column(
          mainAxisAlignment:
              (!minimal) ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Container(
              width: width,
              padding: EdgeInsets.only(top: (!minimal) ? tiny : 0),
              child: Icon(icon,
                  size: (!minimal) ? height * 0.48 : height*0.6,
                  color: (isClicked! ? onClickColor : null)),
            ),
            !minimal
                ? FittedBox(
                  child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: tiny),
                      child: (widget.subText != null&&widget.subText != "")
                          ? Text(
                              widget.subText!,
                              style: TextStyle(
                                height: widget.subText!.contains("\n")?0.95:null,
                                  fontFamily:
                                      themeData.textTheme.bodyText2!.fontFamily,
                                  color: isClicked!
                                      ? onClickColor
                                      : themeData.textTheme.bodyText2!.color,
                                  fontSize: fontSize??themeData.textTheme.bodyText2!.fontSize),
                              textAlign: widget.subTextAlign??TextAlign.center,
                            )
                          : Center(),
                    ),
                )
                : Center()
          ],
        ),
      ),
    );
  }

  void _toggle(bool value) {
    if (!isActivate!) {
      setState(() {
        isClicked = value;
      });
    }
  }

  void _tapDown() => _toggle(true);

  void _tapUp() => _toggle(false);
}

//used for login
class ButtonType3 extends StatefulWidget {
  String text;
  ThemeData themeData;
  Function onPressed;
  double height, width;
  double?  offset;
  TextStyle? textStyle;
  Color? bgColor;
  bool isbnw; //when a button text has to opposite from bg color

  ButtonType3(
      {required this.text,
      required this.height,
      required this.themeData,
      required this.onPressed,
      required this.width,
      this.textStyle,
      this.bgColor,
      this.isbnw = false,
      this.offset});

  @override
  _ButtonType3State createState() => _ButtonType3State();
}

class _ButtonType3State extends State<ButtonType3> {
  late String text;
  late ThemeData themeData;
  late Function onPressed;
  late double height, width;
  late double offset;

  Color? color, textcolor;

  Color? darkColor, shadowColorDark;
  Color? lightColor, shadowColorLight;
  Gradient? gradient;

  List<BoxShadow>? shadowList;
  bool _isPressed = false;
  TextStyle? textStyle;

  late ThemeMode _themeMode;

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    themeData = widget.themeData;
  // deciding _themeMode as light or dark
  _themeMode = themeData.backgroundColor==Color(0xFF2b394e)?ThemeMode.dark:ThemeMode.light;
  text = widget.text;
  onPressed = widget.onPressed;
  height = widget.height;
  width = widget.width;
  textStyle = widget.textStyle;
  offset = widget.offset ?? 5;
  color = widget.bgColor ?? themeData.focusColor;
  // Color(0xFF04aa6b).withOpacity(1);
  // Color(0xFF04aa6b).withOpacity(1);
  // themeData.focusColor;
  darkColor = _getAdjustColor(color!, -20);
  lightColor = _getAdjustColor(color!, 20);
  shadowColorDark = (_themeMode == ThemeMode.light)
      ? _getAdjustColor(themeData.primaryColorDark, -40)
      : _getAdjustColor(themeData.primaryColorDark, -10);
  shadowColorLight = (_themeMode == ThemeMode.light)
      ? _getAdjustColor(themeData.primaryColorDark, 40)
      : _getAdjustColor(themeData.primaryColorDark, 10);
  if (widget.isbnw) {
    if (_themeMode == ThemeMode.light) {
      textcolor = shadowColorDark!.withOpacity(0.9);
    }
    if (_themeMode == ThemeMode.dark) {
      textcolor = shadowColorLight!.withOpacity(0.9);
    }
  } else {
    textcolor = Colors.white.withOpacity(0.7);
  }
  gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkColor!, (_isPressed) ? darkColor! : lightColor!],
  );
  shadowList = [
    BoxShadow(
      color: shadowColorLight!,
      offset: Offset(-offset, -offset),
      blurRadius: offset,
    ),
    BoxShadow(
      color: (_isPressed) ? shadowColorLight! : shadowColorDark!,
      offset: Offset(offset, offset),
      blurRadius: offset,
    ),
  ];
    return GestureDetector(
      onTapDown: (_) => _tapDown(),
      onTapUp: (_) => _tapUp(),
      onTapCancel: _tapUp,
      onTap: onPressed as void Function()?,
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, height * 0.2),
        height: height,
        width: width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            gradient: gradient,
            boxShadow: shadowList),
        child: Center(
            child: Text(
          text,
          style: TextStyle(
            fontFamily: themeData.textTheme.headline3!.fontFamily,
            fontSize: themeData.textTheme.headline3!.fontSize,
            fontStyle: themeData.textTheme.headline3!.fontStyle,
            // fontWeight: themeData.textTheme.headline3!.fontWeight,
            color: textcolor,
          ),
        )),
      ),
    );
  }

  Color _getAdjustColor(Color baseColor, double amount) {
    Map<String, int> colors = {
      'r': baseColor.red,
      'g': baseColor.green,
      'b': baseColor.blue
    };

    colors = colors.map((key, value) {
      if (value + amount < 0) {
        return MapEntry(key, 0);
      }
      if (value + amount > 255) {
        return MapEntry(key, 255);
      }
      return MapEntry(key, (value + amount).floor());
    });
    return Color.fromRGBO(colors['r']!, colors['g']!, colors['b']!, 1);
  }

  void _toggle(bool value) {
    if (_isPressed != value) {
      setState(() {
        _isPressed = value;
      });
    }
  }

  void _tapDown() => _toggle(true);

  void _tapUp() => _toggle(false);
}

// text type buttons
class ButtonType4 extends StatelessWidget {
  final ThemeData? themeData;
  final String? text;
  bool isWhite;
  final Function? onPressed;
  TextStyle? style;

  ButtonType4({this.themeData, this.text, this.onPressed,this.isWhite=false,this.style});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed as void Function()?,
      child: Container(
          child: Text(
        text!,
        style: style!=null?style:(isWhite?themeData!.textTheme.subtitle1:themeData!.textTheme.subtitle2),
      )),
    );
  }
}
