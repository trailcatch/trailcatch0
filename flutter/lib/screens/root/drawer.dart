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
import 'package:trailcatch/widgets/buttons/gesture_button.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.clBlack,
      elevation: 0,
      width: (context.width / 1.8),
      child: SafeArea(
        child: Container(
          height: context.height,
          width: (context.width / 1.8),
          padding: const EdgeInsets.only(left: 5),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    10.h,
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.asset(
                        'assets/***/app_icon_tr.png',
                        cacheHeight: 60 * 3,
                        cacheWidth: 60 * 3,
                      ),
                    ),
                    30.h,
                    DrawerItem(
                      title: 'Subscription',
                      icon: Icons.card_membership_rounded,
                      onTap: () {
                        Navigator.of(context).pop();
                        AppRoute.goTo('/settings_subscription');
                      },
                    ),
                    4.h,
                    0.hrr(
                      color: AppTheme.clText02,
                      height: 0.5,
                      padLR: AppTheme.appLR,
                    ),
                    DrawerItem(
                      title: 'Invite friends',
                      icon: Icons.person_add_alt,
                      onTap: () async {
                        Navigator.of(context).pop();
                        appVM.shareProfile(appVM.user);
                      },
                    ),
                    4.h,
                    0.hrr(
                      color: AppTheme.clText02,
                      height: 0.5,
                      padLR: AppTheme.appLR,
                    ),
                    DrawerItem(
                      title: 'Search People',
                      icon: Icons.person_search,
                      onTap: () async {
                        Navigator.of(context).pop();
                        AppRoute.goSheetTo('/radar_search');
                      },
                    ),
                    40.h,
                    DrawerItem(
                      title: 'Your City',
                      icon: Icons.home_outlined,
                      color: appVM.yourCity == null
                          ? AppTheme.clYellow
                          : AppTheme.clText,
                      onTap: () {
                        Navigator.of(context).pop();
                        AppRoute.goTo('/profile_your_city');
                      },
                    ),
                    4.h,
                    0.hrr(
                      color: AppTheme.clText02,
                      height: 0.5,
                      padLR: AppTheme.appLR,
                    ),
                    DrawerItem(
                      title: 'Notifications',
                      icon: Icons.markunread_mailbox_outlined,
                      onTap: () {
                        Navigator.of(context).pop();
                        AppRoute.goTo('/notifications');
                      },
                    ),
                    4.h,
                    0.hrr(
                      color: AppTheme.clText02,
                      height: 0.5,
                      padLR: AppTheme.appLR,
                    ),
                    DrawerItem(
                      title: 'Trails',
                      icon: Icons.dashboard_customize_outlined,
                      onTap: () {
                        Navigator.of(context).pop();
                        AppRoute.goTo('/trails');
                      },
                    ),
                    40.h,
                    DrawerItem(
                      title: 'Settings',
                      icon: Icons.settings,
                      onTap: () {
                        Navigator.of(context).pop();
                        AppRoute.goTo('/settings');
                      },
                    ),
                    4.h,
                    0.hrr(
                      color: AppTheme.clText02,
                      height: 0.5,
                      padLR: AppTheme.appLR,
                    ),
                    DrawerItem(
                      title: 'About',
                      icon: Icons.info_outline,
                      onTap: () {
                        Navigator.of(context).pop();
                        AppRoute.goTo('/about');
                      },
                    ),
                    const Spacer(flex: 1),
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () async {
                          AppRoute.showPopup(
                            [
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
                        child: Container(
                          color: AppTheme.clBlack,
                          padding: const EdgeInsets.all(10),
                          child: const Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.clRed,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppGestureButton(
      onTap: onTap,
      child: Container(
        height: 50,
        color: AppTheme.clBlack,
        child: Row(
          children: [
            10.w,
            Icon(
              icon,
              color: color ?? AppTheme.clText,
              size: 22,
            ),
            10.w,
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 0.6,
                fontWeight: FontWeight.bold,
                color: color ?? AppTheme.clText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
