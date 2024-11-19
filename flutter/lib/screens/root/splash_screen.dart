// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:trailcatch/context.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    scheduleMicrotask(_initVMs);

    super.initState();
  }

  Future<void> _initVMs() async {
    appContext = context;

    await appVM.init1();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: AppTheme.clBackground,
        width: context.width,
        height: context.height,
        child: Center(
          child: Image.asset(
            'assets/***/app_icon.png',
            width: 250,
            height: 250,
            cacheHeight: 250,
            cacheWidth: 250,
          ),
        ),
      ),
    );
  }
}
