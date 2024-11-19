// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trailcatch/getit.dart';
import 'package:trailcatch/screens/home/home_screen.dart';
import 'package:trailcatch/screens/profile/profile_screen.dart';
import 'package:trailcatch/screens/radar/radar_screen.dart';
import 'package:trailcatch/screens/root/drawer.dart';
import 'package:trailcatch/viewmodels/app_viewmodel.dart';
import 'package:trailcatch/widgets/bottom_nav.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<AppViewModel>();

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        sizing: StackFit.loose,
        index: appVM.tab,
        children: const [
          HomeScreen(),
          RadarScreen(),
          ProfileScreen(),
        ],
      ),
      endDrawer: const AppDrawer(),
      endDrawerEnableOpenDragGesture: false,
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}
