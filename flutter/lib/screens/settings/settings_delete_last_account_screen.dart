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
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class SettingsDeleteLastAccountScreen extends StatelessWidget {
  const SettingsDeleteLastAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSimpleScaffold(
      title: 'Farewell Message',
      onBack: () async {
        AppRoute.goTo('/init');
      },
      wBottom: AppSimpleButton(
        width: context.width * AppTheme.appBtnWidth,
        text: 'Exit',
        onTap: () {
          AppRoute.goTo('/init');
        },
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          30.h,
          Image.asset(
            '***/images/app_icon_tr.png',
            width: 140,
            height: 140,
            cacheHeight: 140,
            cacheWidth: 140,
          ),
          60.h,
          Container(
            alignment: Alignment.center,
            child: const Text(
              'Thank you for being with TrailCatch!',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppTheme.clText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          6.h,
          Container(
            alignment: Alignment.center,
            child: const Text(
              'Movement is life, so never stop :)',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppTheme.clText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          60.h,
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
            child: Text(
              'TrailCatch Team',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          15.h,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: Image.asset('***/***/team_me.jpg'),
                      ),
                    ),
                    10.h,
                    const Text(
                      'Ihar',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                50.w,
                Column(
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: Image.asset(
                          'assets/***/luuuusi.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    10.h,
                    const Text(
                      'Lusi',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
