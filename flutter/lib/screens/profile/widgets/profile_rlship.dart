// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/widgets/tcid.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/avatar_image.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';

class ProfileRlship extends StatelessWidget {
  const ProfileRlship({
    super.key,
    required this.trailExt,
    this.trailId,
  });

  final TrailExtModel trailExt;
  final String? trailId;

  @override
  Widget build(BuildContext context) {
    String status = 'No';
    Color color = AppTheme.clText;

    if (trailExt.user.rlship == 1) {
      status = 'Yes';
      color = AppTheme.clYellow;
    } else if (trailExt.user.rlship == 0) {
      status = 'Hidden';
      color = AppTheme.clRed;
    }

    String ageGroupStr = fnAgeGroup(
      gender: trailExt.user.gender,
      age: trailExt.user.age,
    );

    return Container(
      color: AppTheme.clBackground,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
      width: context.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppGestureButton(
            onTry: () async {
              AppRoute.goTo('/profile', args: {
                'user': trailExt.user,
              });
            },
            child: Container(
              padding: const EdgeInsets.only(top: 3),
              child: AppAvatarImage(
                utcp: trailExt.user.utcp,
                pictureFile: trailExt.user.cachePictureFile,
              ),
            ),
          ),
          15.w,
          Expanded(
            child: AppGestureButton(
              onTry: () async {
                AppRoute.goTo('/profile', args: {
                  'user': trailExt.user,
                });
              },
              child: Container(
                color: AppTheme.clBackground,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    2.h,
                    Text(
                      trailExt.user.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    4.h,
                    Text(
                      '@${trailExt.user.username}',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    10.h,
                    if (ageGroupStr.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Age Group:',
                            style: TextStyle(fontSize: 12),
                          ),
                          4.w,
                          Text(
                            ageGroupStr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (trailExt.user.isMe)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'My Account',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.clText04,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Subscribed: ',
                            style: TextStyle(
                              fontSize: 12,
                              decoration: trailExt.user.rlship == 0
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          4.w,
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          15.w,
          GestureDetector(
            onTap: () {
              if (trailId != null) {
                AppRoute.goTo('/trail_card', args: {
                  'trailId': trailId,
                });
              } else {
                if (trailExt.trail.isEmpt) return;

                AppRoute.goTo('/trail_card', args: {
                  'trailExt': trailExt,
                });
              }
            },
            child: AppTCID(
              trail: trailExt.trail,
            ),
          ),
        ],
      ),
    );
  }
}
