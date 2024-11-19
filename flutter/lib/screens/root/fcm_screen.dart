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

class FcmScreen extends StatelessWidget {
  const FcmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSimpleScaffold(
      title: 'Set Up Notifications',
      onBack: () async {
        appVM.showFcmDesc = false;
        await appVM.initFCM();
        AppRoute.goBack();
      },
      wBottom: AppSimpleButton(
        onTry: () async {
          appVM.showFcmDesc = false;
          await appVM.initFCM();
          AppRoute.goBack();
        },
        width: context.width * AppTheme.appBtnWidth,
        text: 'Set Up Notifications',
        textColor: AppTheme.clYellow,
        borderColor: AppTheme.clYellow,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: context.width,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.appLR,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    10.h,
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: AppTheme.clBlack,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: Image.asset(
                              'assets/***/fcm1.jpg',
                            ),
                          ),
                        ),
                      ],
                    ),
                    20.h,
                    Text(
                      'Push notifications ensure you never miss trail likes and keep you updated on your new subscribers.',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    0.dl,
                    Text(
                      'TrailCatch monitors for new events every 5 minutes, and sends you a single notification or groups them together.',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    30.h,
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: AppTheme.clBlack,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: Image.asset(
                              'assets/***/fcm2.jpg',
                            ),
                          ),
                        ),
                      ],
                    ),
                    20.h,
                    Text(
                      'Only likes and new subscribers - just what matters most to you.',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    0.dl,
                    Text(
                      'No flooding, no spam.',
                      style: TextStyle(
                        fontSize: 17,
                      ),
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
