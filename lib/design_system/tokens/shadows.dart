import 'package:flutter/material.dart';

class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> none = <BoxShadow>[];

  static const List<BoxShadow> low = <BoxShadow>[
    BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 4)),
  ];
}
