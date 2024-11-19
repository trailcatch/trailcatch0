// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/widgets.dart';

import 'package:trailcatch/utils/core_utils.dart';

class AppGestureButton extends StatelessWidget {
  const AppGestureButton({
    super.key,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onTry,
    required this.child,
  });

  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final Future<dynamic> Function()? onTry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (onTap != null) {
          onTap!.call();
        } else if (onTry != null) {
          return await fnTry(() async {
            return await onTry!.call();
          });
        }
      },
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}
