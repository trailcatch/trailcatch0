// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';

class AppWidgetButton extends StatelessWidget {
  const AppWidgetButton({
    super.key,
    required this.child,
    this.onTap,
    this.pressedOpacity = 1.0,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double? pressedOpacity;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.zero,
      pressedOpacity: pressedOpacity,
      onPressed: onTap,
      child: child,
    );
  }
}
