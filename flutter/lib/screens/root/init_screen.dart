// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  final Map<String, String> features = {
    'Profile & Dogs':
        'Complete your profile and embark on new adventures together! Whether you love walking, running, or biking with your dogs, TrailCatch is the perfect companion for all your outdoor pursuits.',
    'Statistics':
        'Curious about your stats for the last month or even the entire year? Check out the statistics page and take a moment to admire all your amazing achievements.',
    'Radar':
        'No one can access your trail\'s exact geolocation - only approximate distances from nearby cities are visible. Give it a try, and you\'ll be amazed at how intriguing it all looks!',
    'GeoLocation':
        'Your privacy comes first. Choose what personal data to show or hide, with complete confidence - especially your GeoLocation, which is always encrypted and never shared with third parties.',
    'Trails':
        'Design your own epic trails and share them with friends! Collect trail likes, unlock beautiful achievement graphs, and watch your adventures come to life in vibrant detail.',
    'Trail Graph':
        'Curious about your trail stats - heart rate, cadence, power, calories, and more? Sync effortlessly with popular devices to capture every detail and elevate your journey!',
    'Share with Friends':
        'Share your achievements with friends and embark on trails together! Don\'t forget to bring your beloved dogs along for the adventure - it\'s always more fun with furry companions.',
    'Search Filters':
        'Looking for trails perfect for walking, running or biking with a specific breed of dog? Use our filter to effortlessly discover trails tailored to your and your furry friend\'s interests.',
    'Nearby Your City':
        'Set your city and discover trails shared by others nearby. Your trail\'s geolocation is securely protected within our database, keeping your location private and safe.',
    'Devices & FIT':
        'Connect your favorite devices or smartwatches to TrailCatch and seamlessly add new trails. Customize your experience by choosing which data to sync - keeping only what matters to you!',
  };

  int _index = 0;

  @override
  void initState() {
    scheduleMicrotask(() {
      if (stVM.isError) {
        Future.delayed(250.mlsec, stVM.unwrap);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Container(
          height: context.height,
          width: context.width,
          color: AppTheme.clBackground,
          child: Column(
            children: [
              10.h,
              SizedBox(
                width: context.width,
                child: Container(
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.asset(
                          'assets/***/app_icon.png',
                          cacheHeight: 50 * 3,
                          cacheWidth: 50 * 3,
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          'TrailCatch',
                          style: TextStyle(
                            fontSize: 34,
                            color: AppTheme.clYellow,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              30.h,
              Expanded(
                child: PageView(
                  physics: const ClampingScrollPhysics(),
                  onPageChanged: (value) {
                    setState(() {
                      _index = value;
                    });
                  },
                  children: [
                    for (var inx in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]) ...[
                      Column(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                border: Border.all(
                                  width: 2,
                                  color: AppTheme.clBlack,
                                ),
                              ),
                              child: Image.asset(
                                'assets/***/***/init${inx + 1}.png',
                                cacheHeight: 1035,
                                cacheWidth: 477,
                              ),
                            ),
                          ),
                          20.h,
                          Container(
                            height: 130,
                            alignment: Alignment.topCenter,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.appLR * 2),
                            child: Container(
                              padding: const EdgeInsets.only(top: 5),
                              child: Column(
                                children: [
                                  Text(
                                    features.entries.elementAt(inx).key,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.clYellow,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  8.h,
                                  Text(
                                    features.entries.elementAt(inx).value,
                                    style: TextStyle(),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var inx in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]) ...[
                      Container(
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.clYellow
                              .withOpacity(_index == inx ? 1 : 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (inx != 11) 6.w,
                    ],
                  ],
                ),
              ),
              15.h,
              AppSimpleButton(
                text: 'Join TrailCatch',
                width: context.width * AppTheme.appBtnWidth,
                onTap: () async {
                  AppRoute.goTo('/join');
                },
              ),
              AppSimpleButton(
                text: 'Try Demo',
                width: context.width * AppTheme.appBtnWidth,
                onTap: () async {
                  AppRoute.goTo('/demo');
                },
              ),
              10.h,
            ],
          ),
        ),
      ),
    );
  }
}
