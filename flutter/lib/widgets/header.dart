// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/theme.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.fontSize,
    this.fontWeight,
    this.isDanger = false,
    this.margin,
  });

  final String title;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool isDanger;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isDanger) 0.hrr(color: AppTheme.clRed06, height: 2),
        Container(
          color: AppTheme.clBlack,
          width: context.width,
          padding: const EdgeInsets.only(bottom: 5, top: 5),
          margin: margin ??
              EdgeInsets.symmetric(vertical: isDanger ? 0 : AppTheme.appDL),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: fontSize ?? 18,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ),
        if (isDanger) 0.hrr(color: AppTheme.clRed06, height: 2),
      ],
    );
  }
}
