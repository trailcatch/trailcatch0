// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class DemoSheet extends StatelessWidget {
  const DemoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBottomScaffold(
      title: 'Demo',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            10.h,
            Text(
              'This feature isn’t available for demo accounts.',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
