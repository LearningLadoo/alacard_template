import 'package:flutter/material.dart';

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach => this.split(" ").map((str) => str.inCaps).join(" ");
}
extension Hex on String {
  Color get colorFromHex {
    final buffer = StringBuffer();
    if (this.length == 6 || this.length == 7) buffer.write('ff');
    buffer.write(this);
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
extension HexColors on Color {
  String colorToHex({bool withAlpha = false,bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${withAlpha?this.alpha.toRadixString(16).padLeft(2, '0'):""}'
      '${this.red.toRadixString(16).padLeft(2, '0')}'
      '${this.green.toRadixString(16).padLeft(2, '0')}'
      '${this.blue.toRadixString(16).padLeft(2, '0')}';
}
