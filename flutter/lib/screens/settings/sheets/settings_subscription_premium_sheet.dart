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

class SettingsSubscriptionPremiumSheet extends StatelessWidget {
  const SettingsSubscriptionPremiumSheet({
    super.key,
    required this.premiumPrice,
  });

  final String premiumPrice;

  @override
  Widget build(BuildContext context) {
    final String fromDtStr = fnDateFormat(
      'd MMM yyyy',
      DateTime.now(),
    );
    final String toDtStr = fnDateFormat(
      'd MMM yyyy',
      addMonth(DateTime.now()),
    );

    return AppBottomScaffold(
      title: 'Premium Plan',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Premium Plan starts today, on $fromDtStr.',
            ),
            10.h,
            Text(
              'And will be active through a month, approximately until a day $toDtStr.',
            ),
            10.h,
            Text(
              'It will be available at a monthly cost of\n$premiumPrice.',
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
                text: 'Purchase Premium Plan',
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
