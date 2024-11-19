// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/theme.dart';

class AppHr extends StatelessWidget {
  const AppHr(
    this.topPadding,
    this.bottomPadding, {
    super.key,
    this.color,
  });

  final Color? color;
  final double? topPadding;
  final double? bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        (topPadding ?? 0).toInt().h,
        Container(
          color: color ?? AppTheme.clText.withOpacity(0.2),
          height: 0.5,
          width: context.width,
        ),
        (bottomPadding ?? 0).toInt().h,
      ],
    );
  }
}

class AppHrBlack extends StatelessWidget {
  const AppHrBlack({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: 5,
      width: context.width,
    );
  }
}
