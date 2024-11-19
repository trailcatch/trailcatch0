// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:trailcatch/constants.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/pref_utils.dart';
import 'package:trailcatch/widgets/buttons/option_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class SettingsLanguageScreen extends StatefulWidget {
  const SettingsLanguageScreen({super.key});

  @override
  State<SettingsLanguageScreen> createState() => _SettingsLanguageScreenState();
}

class _SettingsLanguageScreenState extends State<SettingsLanguageScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    Future<void> setLang(String lang) async {
      if (lang == appVM.lang || lang.isEmpty) return;

      setState(() => _loading = true);
      await Future.delayed(250.mlsec);

      appVM.setLang(lang);
      await fnPrefSaveLang(appVM.lang);

      await userServ.fnUsersUpdate(lang: appVM.lang);

      setState(() => _loading = false);
    }

    return AppSimpleScaffold(
      title: 'Language',
      loading: _loading,
      onBack: () async {
        // setState(() => _loading = true);

        // await userServ.fnUsersUpdate(lang: appVM.lang);

        // setState(() => _loading = false);

        AppRoute.goBack();
      },
      children: [
        10.h,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sort_by_alpha_rounded,
              size: 17,
              color: AppTheme.clText05,
            ),
            6.w,
            const Text(
              'Sorted by alphabite',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.clText05,
              ),
            ),
          ],
        ),
        15.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppOptionButton(
            htitle: 'English',
            value: appVM.lang == 'en' ? 'On' : 'Off',
            opts: const ['Off', 'On'],
            onValueChanged: (value) {
              // if (value == 'Off') return;

              // setLang('en');
            },
          ),
        ),
        0.dl,
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: Text(
            '* more languages will be ${cstAvlShortly.toLowerCase()}',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.clText05,
            ),
          ),
        ),
      ],
    );
  }
}
