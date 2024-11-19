// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/theme.dart';

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        color: AppTheme.clText08,
        strokeWidth: 1.5,
      ),
    );
  }
}

class AppProgressIndicatorCenter extends StatelessWidget {
  const AppProgressIndicatorCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      height: context.height,
      color: AppTheme.clBackground05,
      child: const Center(child: AppProgressIndicator()),
    );
  }
}

class AppProgressIndicatoEmpty extends StatelessWidget {
  const AppProgressIndicatoEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      height: context.height,
      color: AppTheme.clTransparent,
    );
  }
}
