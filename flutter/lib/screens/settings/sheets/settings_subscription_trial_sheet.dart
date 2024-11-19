// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class SettingsSubscriptionTrialSheet extends StatelessWidget {
  const SettingsSubscriptionTrialSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final String fromDtStr = fnDateFormat(
      'd MMM yyyy',
      DateTime.now(),
    );
    final String toDtStr = fnDateFormat(
      'd MMM yyyy',
      DateTime.now().add(const Duration(days: 30)),
    );

    return AppBottomScaffold(
      title: 'Free 30-day Trial Plan',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your free 30-day Trial Plan starts today, on $fromDtStr.',
            ),
            10.h,
            Text(
              'And will be active through 30 days, approximately until a day $toDtStr.',
            ),
            10.h,
            Text(
              'You won\'t need to make any payment.',
              style: TextStyle(
                color: AppTheme.clYellow,
                fontWeight: FontWeight.bold,
              ),
            ),
            10.h,
            Text(
              'After 30 days, your plan will automatically revert to the Free Plan. To continue enjoying Premium features after this period, you’ll need to purchase the Premium Plan.',
            ),
            20.h,
            Text(
              'Enjoy your enhanced experience!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            40.h,
            Center(
              child: AppSimpleButton(
                text: 'Privacy Policy',
                width: context.width * AppTheme.appBtnWidth,
                onTap: () async {
                  launchUrl(Uri.parse('https://trailcatch.com/policy'));
                },
              ),
            ),
            Center(
              child: AppSimpleButton(
                text: 'Terms and Conditions',
                width: context.width * AppTheme.appBtnWidth,
                onTap: () async {
                  launchUrl(Uri.parse('https://trailcatch.com/terms'));
                },
              ),
            ),
            15.h,
            Center(
              child: AppSimpleButton(
                text: 'Try free 30-day Trial Plan',
                width: context.width * AppTheme.appBtnWidth,
                textColor: AppTheme.clYellow,
                borderColor: AppTheme.clYellow,
                onTap: () async {
                  AppRoute.goBack(true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
