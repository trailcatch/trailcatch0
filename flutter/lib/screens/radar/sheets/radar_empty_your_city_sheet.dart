// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class RadarEmptyYourCitySheet extends StatelessWidget {
  const RadarEmptyYourCitySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBottomScaffold(
      title: 'Your City',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
        child: Column(
          children: [
            Text(
              'To make the most of the Radar feature, please set your city.',
            ),
            10.h,
            Text(
              'Each trail has either one or three geolocation points, used to calculate the distance between the trail and its nearest city.',
            ),
            10.h,
            Text(
              'Double-tap on the Radar to discover more cities and their distances.',
            ),
            10.h,
            Text(
              'All trails you see on Radar are sorted based on your selected city, with the closest trails to the city center shown first.',
            ),
            10.h,
            Text(
              'The idea is that you’ll see cities closest to the center point of your selected city, and Radar will display the distances of trails belonging to the nearest city for each.',
            ),
            10.h,
            Text(
              'When a trail has one or three geolocation points, the first (or single) point is always at least 200 meters from the trail\'s start, the second marks the midpoint, and the third is always at least 200 meters before the trail\'s end.',
            ),
            20.h,
            Center(
              child: AppSimpleButton(
                width: context.width * AppTheme.appBtnWidth,
                textColor: AppTheme.clYellow,
                borderColor: AppTheme.clYellow,
                text: 'Set Your City',
                onTap: () async {
                  await AppRoute.goTo('/profile_your_city');

                  if (appVM.yourCity != null) {
                    AppRoute.goSheetBack();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
