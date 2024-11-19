// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/viewmodels/app_viewmodel.dart';
import 'package:trailcatch/widgets/buttons/option_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class SettingsNotificationsScreen extends StatelessWidget {
  const SettingsNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<AppViewModel>();

    return AppSimpleScaffold(
      title: 'Push Notifications',
      children: [
        10.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(28)),
            child: Image.asset(
              'assets/***/fcm2.jpg',
            ),
          ),
        ),
        30.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppOptionButton(
            htitle: 'Trail Likes',
            value: appVM.settings.notifPushLikes ? 'On' : 'Off',
            opts: const ['Off', 'On'],
            onValueChanged: (value) async {
              if (fnIsDemo(silence: false)) return;

              if (value == 'Off') {
                if (appVM.settings.notifPushLikes != false) {
                  userServ.fnUsersUpdate(notifPushLikes: false);

                  appVM.settings.notifPushLikes = false;
                  appVM.notify();
                }
              } else if (value == 'On') {
                if (appVM.settings.notifPushLikes != true) {
                  userServ.fnUsersUpdate(notifPushLikes: true);

                  appVM.settings.notifPushLikes = true;
                  appVM.notify();
                }
              }
            },
          ),
        ),
        5.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          alignment: Alignment.centerLeft,
          child: Text(
            'Let me know when someone likes my trail',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.clText08,
            ),
          ),
        ),
        0.dl,
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppOptionButton(
            htitle: 'New Subscribers',
            value: appVM.settings.notifPushSubscribers ? 'On' : 'Off',
            opts: const ['Off', 'On'],
            onValueChanged: (value) async {
              if (fnIsDemo(silence: false)) return;

              if (value == 'Off') {
                if (appVM.settings.notifPushSubscribers != false) {
                  userServ.fnUsersUpdate(notifPushSubscribers: false);

                  appVM.settings.notifPushSubscribers = false;
                  appVM.notify();
                }
              } else if (value == 'On') {
                if (appVM.settings.notifPushSubscribers != true) {
                  userServ.fnUsersUpdate(notifPushSubscribers: true);

                  appVM.settings.notifPushSubscribers = true;
                  appVM.notify();
                }
              }
            },
          ),
        ),
        5.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          alignment: Alignment.centerLeft,
          child: Text(
            'Notify me when someone subscribes to me',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.clText08,
            ),
          ),
        ),
        10.h,
        20.hrr(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TrailCatch monitors for new events every 5 minutes, and sends you a single notification or groups them together.',
              ),
              0.dl,
              Text(
                'Only likes and new subscribers - just what matters most to you.',
              ),
              0.dl,
              Text(
                'No flooding, no spam.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
