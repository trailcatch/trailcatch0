// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class DevicesTrailExistsSheet extends StatelessWidget {
  const DevicesTrailExistsSheet({
    super.key,
    required this.trailId,
  });

  final String trailId;

  @override
  Widget build(BuildContext context) {
    return AppBottomScaffold(
      title: 'Existed Trail ',
      child: Column(
        children: [
          Container(
            width: context.width,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR * 2),
            child: Text(
              'The trail already exists.',
              style: TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          20.h,
          AppSimpleButton(
            width: context.width * AppTheme.appBtnWidth,
            onTap: () async {
              await AppRoute.goSheetBack();

              AppRoute.goTo(
                '/trail_card',
                args: {
                  'trailId': trailId,
                },
              );
            },
            text: 'Go to Trail',
          ),
        ],
      ),
    );
  }
}
