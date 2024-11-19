// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:trailcatch/extensions.dart';

import 'package:trailcatch/theme.dart';

class AppText extends Text {
  const AppText._(super.text, TextStyle style) : super(style: style);

  factory AppText.tsRegular(text) => AppText._(text, AppTheme.tsRegular);
  factory AppText.tsMedium(text) => AppText._(text, AppTheme.tsMedium);

  //+ ts

  static Text ts14(text, [Color? color = AppTheme.clText]) {
    return AppText.tsRegular(text).tsFontSize(14).tsColor(color);
  }

  static Text ts16(text, [Color? color = AppTheme.clText]) {
    return AppText.tsRegular(text).tsFontSize(16).tsColor(color);
  }

  static Text ts17(text, [Color? color = AppTheme.clText]) {
    return AppText.tsRegular(text).tsFontSize(17).tsColor(color);
  }

  static Text ts20(text, [Color? color = AppTheme.clText]) {
    return AppText.tsRegular(text).tsFontSize(20).tsColor(color);
  }

  //-
}
