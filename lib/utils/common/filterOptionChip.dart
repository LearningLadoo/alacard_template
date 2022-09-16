import 'package:alacard_template/constants.dart';
import 'package:flutter/material.dart';

class FilterOptionChip extends StatelessWidget {
  Filter selectedFilter;
  Filter filterName;
  Function onChangedFn;
  FilterOptionChip({required this.filterName,required this.selectedFilter,required this.onChangedFn});
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    Color? color;
    Color? darkColor;
    Color? lightColor;
    color = themeData.colorScheme.onPrimary;
    darkColor = _getAdjustColor(color, -20);
    lightColor = _getAdjustColor(color, 20);
    // making the filter options look better
    String name = "";
    int m = 0;
    for(String i in filterName.name.split("")){
      if(i==i.toUpperCase()){
        name+=" "+i;
      } else if(m==0){
        name+=i.toUpperCase();
      } else {
        name+=i;
      }
      m++;
    }
    return chip(label: name, height: medium*1.4, isSelected: selectedFilter == filterName,onChangedFn: onChangedFn);
  }
}
Widget chip({required String label, required double height, required bool isSelected,required Function onChangedFn }){
  ThemeData themeData = Theme.of(bc_currContext!);
  return FittedBox(
    child: SizedBox(
      height: medium*1.4,
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onChangedFn as bool? Function(bool?)?,
        pressElevation: 0.0,
        shadowColor: Colors.transparent,
        selectedColor: themeData.colorScheme.onPrimary,
        selectedShadowColor: Colors.transparent,
        backgroundColor: themeData.primaryColorDark.withOpacity(0.8),
        elevation: 0,
        checkmarkColor: themeData.shadowColor,
        labelStyle: TextStyle(
            fontSize: themeData.textTheme.bodyText1!.fontSize,
            fontFamily: themeData.textTheme.bodyText1!.fontFamily,
            color: isSelected ? themeData.shadowColor : themeData.colorScheme.onPrimary),
      ),
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
