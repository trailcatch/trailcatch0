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

class Error404Screen extends StatelessWidget {
  const Error404Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSimpleScaffold(
      title: 'Error 404',
      onBack: () async {
        AppRoute.showPopup(
          [
            AppPopupAction(
              'Reload',
              color: AppTheme.clYellow,
              () => AppRoute.goTo('/splash'),
            ),
            AppPopupAction(
              'Log Out',
              color: AppTheme.clRed,
              () async {
                await appVM.signOut();
              },
            ),
          ],
        );
      },
      wBottom: Column(
        children: [
          AppSimpleButton(
            onTry: () async {
              AppRoute.goSheetTo('/error404_bug');
            },
            width: context.width * AppTheme.appBtnWidth,
            text: 'Report Bug',
          ),
          10.h,
          AppSimpleButton(
            onTry: () async {
              AppRoute.goSheetTo('/error404_support');
            },
            width: context.width * AppTheme.appBtnWidth,
            text: 'Contact Support',
          ),
          10.h,
          AppSimpleButton(
            onTry: () async {
              AppRoute.goTo('/splash');
            },
            width: context.width * AppTheme.appBtnWidth,
            text: 'Give TrailCatch a quick reload!',
            textColor: AppTheme.clYellow,
            borderColor: AppTheme.clYellow,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
        height: context.heightScaffold,
        child: Column(
          children: [
            20.h,
            Text(
              'Oops! Looks like something went off trail.',
              style: TextStyle(
                fontSize: 18,
                height: 1.6,
              ),
            ),
            6.h,
            Text(
              'Let\'s get you back on track!',
              style: TextStyle(
                fontSize: 18,
                height: 1.6,
              ),
            ),
            const Spacer(),
            Image.asset(
              'assets/***/app_icon_tr.png',
              width: 100,
              height: 100,
              cacheHeight: 100,
              cacheWidth: 100,
              color: AppTheme.clText01,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
