// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';
import 'package:trailcatch/constants.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/screens/settings/settings_subscription_screen.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class TrailNotAllowPubSheet extends StatefulWidget {
  const TrailNotAllowPubSheet({
    super.key,
  });

  @override
  State<TrailNotAllowPubSheet> createState() => _TrailNotAllowPubSheetState();
}

class _TrailNotAllowPubSheetState extends State<TrailNotAllowPubSheet> {
  @override
  Widget build(BuildContext context) {
    return AppBottomScaffold(
      title: 'Trail Publish Limit',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Your Plan',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.clText05,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Free Plan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            0.dl,
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.appLR, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: AppTheme.clBlack,
              ),
              child: Column(
                children: [
                  Text(
                    'With the Free Plan, you can publish only up to $cstFreeTrailPerWeek trails per week.',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  15.h,
                  EmptyFreeTrails(),
                ],
              ),
            ),
            0.dl,
            Center(
              child: AppSimpleButton(
                width: context.width * AppTheme.appBtnWidth,
                text: 'Update to Premium Plan',
                textColor: AppTheme.clYellow,
                borderColor: AppTheme.clYellow,
                onTry: () async {
                  await AppRoute.goSheetBack();
                  AppRoute.goTo('/settings_subscription');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
