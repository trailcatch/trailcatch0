// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class TtrScreen extends StatelessWidget {
  const TtrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSimpleScaffold(
      title: 'App Tracking Transparency',
      onBack: () async {
        appVM.showTtrDesc = false;
        await appVM.initTrackTr();
        AppRoute.goBack();
      },
      wBottom: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
            child: Text(
              'TrailCatch will never share or sell your personal data to any third party or service.',
              style: TextStyle(
                fontSize: 17,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          30.h,
          AppSimpleButton(
            onTry: () async {
              appVM.showTtrDesc = false;
              await appVM.initTrackTr();
              AppRoute.goBack();
            },
            width: context.width * AppTheme.appBtnWidth,
            text: 'Set Up',
            textColor: AppTheme.clYellow,
            borderColor: AppTheme.clYellow,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: context.width,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.appLR * 1,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    10.h,
                    Text(
                      'App Tracking Transparency (ATT) is Apple’s privacy framework designed to give users more control over their data.',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    0.dl,
                    Text(
                      'It requires iOS apps to request user permission - through a pop-up prompt, before accessing the Identifier for Advertisers (IDFA) to track the user or device. Introduced with iOS 14.5 in April 2021, ATT was implemented to address increasing concerns about the extent of user data collected and used for tracking and targeting.',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
