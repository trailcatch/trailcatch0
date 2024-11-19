// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class DevicesFitErrorSheet extends StatelessWidget {
  const DevicesFitErrorSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomScaffold(
      title: 'FIT Error',
      child: Column(
        children: [
          Container(
            width: context.width,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR * 2),
            child: Text(
              'Unable to parse the FIT file.',
              style: TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          4.h,
          Container(
            width: context.width,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR * 2),
            child: Text(
              'Please try again or consider using a different file.',
              style: TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          10.h,
        ],
      ),
    );
  }
}
