// License: This file is part of TrailCatch.
// Copyright (c) ***24 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class AppTheme {
  //+ colors palette

  static const Color clBlack = Color.fromARGB(***, ***, ***, ***);
  static const Color clBlack02 = Color.fromARGB(***, ***, ***, ***);

  static const Color clTransparent = Colors.transparent;

  static const Color clYellow = Color.fromARGB(***, ***, ***, ***);
  static const Color clYellow005 = Color.fromARGB(***, ***, ***, ***);
  static const Color clYellow01 = Color.fromARGB(***, ***, ***, ***);
  static const Color clYellow03 = Color.fromARGB(***, ***, ***, ***);
  static const Color clYellow05 = Color.fromARGB(***, ***, ***, ***);
  static const Color clYellow07 = Color.fromARGB(***, ***, ***, ***);
  static const Color clYellow08 = Color.fromARGB(***, ***, ***, ***);

  static const Color clGreen = Colors.green;

  static final Color clGrey900 = Colors.grey[***]!;
  static const Color clGrey27 = Color(***);

  static const Color clBlue = Color.fromARGB(***, ***, ***, ***);
  static const Color clBlue08 = Color.fromARGB(***, ***, ***, ***);

  static const Color clRed = Colors.red;
  static const Color clRed02 = Color.fromARGB(***, ***, ***, ***);
  static const Color clRed03 = Color.fromARGB(***, ***, ***, ***);
  static const Color clRed04 = Color.fromARGB(***, ***, ***, ***);
  static const Color clRed05 = Color.fromARGB(***, ***, ***, ***);
  static const Color clRed06 = Color.fromARGB(***, ***, ***, ***);
  static const Color clRed08 = Color.fromARGB(***, ***, ***, ***);
  static const Color clDeepOrange = Colors.deepOrange;

  // --

  static const Color clBackground = Color.fromARGB(***, ***, ***, ***);
  static const Color clBackground04 = Color.fromARGB(***, ***, ***, ***);
  static const Color clBackground05 = Color.fromARGB(***, ***, ***, ***);
  static const Color clBackground09 = Color.fromARGB(***, ***, ***, ***);

  static const Color clText = Color.fromARGB(***, ***, ***, ***);
  static const Color clText002 = Color.fromARGB(***, ***, ***, ***);
  static const Color clText005 = Color.fromARGB(***, ***, ***, ***);
  static const Color clText01 = Color.fromARGB(***, ***, ***, ***);
  static const Color clText02 = Color.fromARGB(***, ***, ***, ***);
  static const Color clText03 = Color.fromARGB(***, ***, ***, ***);
  static const Color clText04 = Color.fromARGB(***, ***, ***, ***);
  static const Color clText05 = Color.fromARGB(***, ***, ***, ***);
  static const Color clText07 = Color.fromARGB(***, ***, ***, ***);
  static const Color clText08 = Color.fromARGB(***, ***, ***, ***);
  static const Color clText09 = Color.fromARGB(***, ***, ***, ***);

  static const Color clText2 = Color(***);

  //+ sizes

  static const double appBtnHeight = ***;
  static const double appBtnWidth = ***;
  static const double appBtnRadius = ***;

  static const double appTextFieldHeight = ***;

  static const double appLR = ***;
  static const double appDL = ***;
  static const double appTitleHeight = ***;
  static const double appNavHeight = ***;

  static const double appOptionHeigth = appBtnHeight;

  static const double appProfileNavHeight = ***;

  //+ text styles

  static const String ffUbuntuRegular = 'Ubuntu Regular';
  static const String ffUbuntuLight = 'Ubuntu Light';

  static const TextStyle tsRegular = TextStyle(
    fontFamily: ffUbuntuLight,
    fontSize: ***,
    color: clText,
    letterSpacing: 0,
  );

  static const TextStyle tsMedium = TextStyle(
    fontFamily: ffUbuntuLight,
    fontSize: ***,
    color: clText,
    letterSpacing: 0,
    fontWeight: FontWeight.bold,
  );

  //+ media

  static MediaQueryData mediaQuery(BuildContext context) {
    return MediaQuery.of(context).copyWith(
      boldText: false,
      highContrast: false,
      invertColors: false,
    );
  }

  static get() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: clText,
      primaryColorDark: clText,
      primaryColorLight: clText,
      canvasColor: AppTheme.clBackground,
      scaffoldBackgroundColor: AppTheme.clBackground,
      appBarTheme: const AppBarTheme(
        titleTextStyle: tsRegular,
        backgroundColor: AppTheme.clBackground,
      ),
      textTheme: const TextTheme(
        bodyLarge: tsRegular,
        bodyMedium: tsRegular,
        bodySmall: tsRegular,
        displayLarge: tsRegular,
        displayMedium: tsRegular,
        displaySmall: tsRegular,
        headlineLarge: tsRegular,
        headlineMedium: tsRegular,
        headlineSmall: tsRegular,
        labelLarge: tsRegular,
        labelMedium: tsRegular,
        labelSmall: tsRegular,
        titleLarge: tsRegular,
        titleMedium: tsRegular,
        titleSmall: tsRegular,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: clText,
        applyThemeToAll: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppTheme.clBackground,
        barBackgroundColor: AppTheme.clBackground,
        textTheme: CupertinoTextThemeData(
          actionTextStyle: tsRegular,
          dateTimePickerTextStyle: tsRegular,
          navActionTextStyle: tsRegular,
          navLargeTitleTextStyle: tsRegular,
          navTitleTextStyle: tsRegular,
          pickerTextStyle: tsRegular,
          primaryColor: clText,
          tabLabelTextStyle: tsRegular,
          textStyle: tsRegular,
        ),
      ),
    );
  }
}
