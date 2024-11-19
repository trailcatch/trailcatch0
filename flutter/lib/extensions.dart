// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:trailcatch/context.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';

extension IntExt on int {
  SizedBox get h => SizedBox(height: toDouble());
  SizedBox get w => SizedBox(width: toDouble());

  Column get hr {
    return Column(
      children: [
        SizedBox(height: toDouble()),
        Container(
          height: 5,
          width: appContext.width,
          color: AppTheme.clBlack,
        ),
        SizedBox(height: toDouble()),
      ],
    );
  }

  Widget hrr({
    double height = 5,
    Color color = AppTheme.clBlack,
    double padLR = 0,
    Color? border,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padLR),
      child: Column(
        children: [
          Container(
            height: toDouble(),
            width: appContext.width,
            color: border,
          ),
          Container(
            height: height,
            width: appContext.width,
            color: color,
          ),
          Container(
            height: toDouble(),
            width: appContext.width,
            color: border,
          ),
        ],
      ),
    );
  }

  Duration get mlsec {
    return Duration(milliseconds: this);
  }

  SizedBox get dl => const SizedBox(height: AppTheme.appDL);
}

extension DoubleExt on double {
  SizedBox get h => SizedBox(height: toDouble());
  SizedBox get w => SizedBox(width: toDouble());
}

extension BuildContextExt on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  double get statusBar => MediaQuery.of(this).viewPadding.top;
  double get notch => MediaQuery.of(this).viewPadding.bottom;

  double get keyboardHeight => MediaQuery.of(this).viewInsets.bottom;

  double get heightScaffold {
    return height -
        statusBar -
        notch -
        AppTheme.appTitleHeight -
        AppTheme.appNavHeight;
  }
}

extension DateTimeExt on DateTime {
  String toDate({
    bool isY2 = false,
    bool isD = true,
  }) {
    return fnDateFormat(
      "${isD ? 'MMMM d' : 'LLLL'}, ${isY2 ? "''yy" : "yyyy"}",
      this,
    ).toTitle();
  }

  String toSimpleDate() {
    return fnDateFormat('yyyy-MM-dd', this);
  }

  String toTcidDate() {
    return fnDateFormat('dd.MM.yy', this);
  }

  String toTime() {
    return fnTimeFormat(this);
  }

  String toMonthYear({
    bool isY2 = false,
    bool isM3 = false,
  }) {
    return fnDateFormat(
            '${isM3 ? 'LLL' : 'LLLL'} ${isY2 ? "''yy" : "yyyy"}', this)
        .toTitle();
  }

  String toYear({
    bool isY2 = false,
  }) {
    return fnDateFormat(isY2 ? "''yy" : "yyyy", this).toTitle();
  }

  String toMonth({
    bool isM3 = false,
  }) {
    return fnDateFormat(isM3 ? 'LLL' : 'LLLL', this).toTitle();
  }

  String toDayOfWeek() {
    return fnDateFormat('EEEE', this).toTitle();
  }
}

extension StringExt on String {
  String toTitle() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension AppLocalizationsExt on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
