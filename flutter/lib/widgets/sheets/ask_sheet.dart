// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class AppAskSheet extends StatelessWidget {
  const AppAskSheet({
    super.key,
    required this.title,
    required this.text,
    required this.first,
    required this.second,
    this.firstColor,
    this.secondColor,
  });

  final String title;
  final String text;
  final String first;
  final String second;
  final Color? firstColor;
  final Color? secondColor;

  @override
  Widget build(BuildContext context) {
    return AppBottomScaffold(
      title: title,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 17,
              ),
              textAlign: TextAlign.left,
            ),
            30.h,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: context.width * 0.4,
                  child: AppSimpleButton(
                    text: first,
                    textColor: firstColor,
                    fontWeight: FontWeight.bold,
                    onTap: () => AppRoute.goSheetBack(0),
                  ),
                ),
                SizedBox(
                  width: context.width * 0.4,
                  child: AppSimpleButton(
                    text: second,
                    textColor: secondColor,
                    fontWeight: FontWeight.bold,
                    onTap: () => AppRoute.goSheetBack(1),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
