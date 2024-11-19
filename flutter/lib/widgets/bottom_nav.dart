// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/viewmodels/app_viewmodel.dart';

class AppBottomNav extends StatefulWidget {
  const AppBottomNav({super.key});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  @override
  void didChangeDependencies() {
    context.watch<AppViewModel>();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      height: AppTheme.appNavHeight,
      color: AppTheme.clBackground,
      child: Column(
        children: [
          Container(
            width: context.width,
            height: 1.5,
            color: Colors.black,
          ),
          8.h,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BottomNavBtn(
                // icon: Icons.home_outlined,
                icon: Icons.contacts_outlined,
                selected: appVM.tab == 0,
                onPressed: () {
                  if (appVM.tab != 0) {
                    appVM.tab = 0;
                    appVM.notify();
                  }
                },
              ),
              BottomNavBtn(
                // icon: Icons.directions_outlined,
                // icon: Icons.call_split_rounded,
                // icon: Icons.my_location_rounded,
                // icon: Icons.explore_outlined,
                // icon: Icons.near_me_outlined,
                // icon: Icons.navigation_outlined,
                // icon: Icons.location_searching_rounded,
                // icon: Icons.alt_route_rounded,
                // icon: Icons.signpost_outlined,
                icon: Icons.signpost_outlined,
                selected: appVM.tab == 1,
                onPressed: () {
                  if (appVM.tab != 1) {
                    appVM.tab = 1;
                    appVM.notify();
                  }

                  Future.delayed(150.mlsec, appVM.reInitRadarPos);
                },
              ),
              BottomNavBtn(
                icon: Icons.badge_outlined,
                selected: appVM.tab == 2,
                onPressed: () {
                  if (appVM.tab != 2) {
                    appVM.tab = 2;
                    appVM.notify();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BottomNavBtn extends StatelessWidget {
  const BottomNavBtn({
    super.key,
    required this.onPressed,
    required this.selected,
    required this.icon,
  });

  final VoidCallback onPressed;
  final bool selected;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CupertinoButton(
        onPressed: onPressed,
        pressedOpacity: 0.9,
        padding: EdgeInsets.zero,
        child: Container(
          height: AppTheme.appNavHeight - 10,
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: selected ? 2 : 4),
          child: Icon(
            icon,
            size: selected ? 30 : 26,
            color: selected ? AppTheme.clYellow : AppTheme.clText,
          ),
        ),
      ),
    );
  }
}
