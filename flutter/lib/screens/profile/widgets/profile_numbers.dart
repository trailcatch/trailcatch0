// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';

class ProfileNumbers extends StatelessWidget {
  const ProfileNumbers({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final int sCount = user.statsAllYears.count;
    final int sDistance = user.statsAllYears.distance;
    final int sElevation = user.statsAllYears.elevation;

    return Container(
      color: AppTheme.clBackground,
      padding: const EdgeInsets.only(
        left: AppTheme.appLR,
        right: AppTheme.appLR,
        top: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppGestureButton(
            onTap: () {
              AppRoute.goTo('/profile_rlship', args: {
                'user': user,
                'subscriptions': false,
                'hiddens': false,
              });
            },
            child: Container(
              color: AppTheme.clBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subscribers:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                      color: AppTheme.clText08,
                    ),
                  ),
                  Text(
                    fnNumCompact(user.subscribers),
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  18.h,
                ],
              ),
            ),
          ),
          AppGestureButton(
            onTap: () {
              AppRoute.goSheetTo('/profile_top_likes', args: {
                'user': user,
              });
            },
            child: Container(
              color: AppTheme.clBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Likes:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                      color: AppTheme.clText08,
                    ),
                  ),
                  Text(
                    fnNumCompact(user.userLikes),
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  18.h,
                ],
              ),
            ),
          ),
          AppGestureButton(
            onTap: () {
              AppRoute.goTo('/profile_statistics', args: {
                'user': user,
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Trails & Distance:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.clText08,
                  ),
                  textAlign: TextAlign.start,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${'${fnNumCompact(sCount)} / '}${fnDistance(sDistance, compact: true)} ${fnDistUnit()}',
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.clText,
                            ),
                          ),
                        ),
                        Text(
                          'D+ $sElevation',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.clText,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
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
