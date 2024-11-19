// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/utils/demo_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/screens/profile/widgets/profile_git.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  bool _loading = false;

  void _doShelter() {
    AppRoute.showPopup(
      title: 'Dog Shelter',
      [
        AppPopupAction(
          'instagram.com/doghopeorg',
          color: AppTheme.clYellow,
          () async {
            launchUrl(Uri.parse('https://www.instagram.com/doghopeorg'));
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = UserModel.fromJson({
      'user_id': '1',
      'username': '',
      'first_name': '',
      'last_name': '',
      'gender': 1,
      'age': 0,
      'uiso3': '',
      'contacts': Map<String, dynamic>.from({}),
      'utcp': 0,
      'latest_trail_id': '',
      'rlship': 1,
      'subscribers': 0,
      'subscriptions': 0,
      'trails': 0,
      'user_likes': 0,
      'statistics': fnGenDemoStat(),
      'dogs': [],
    });

    return AppSimpleScaffold(
      title: 'TrailCatch Demo',
      loading: _loading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          10.h,
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR + 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    text: 'Welcome and let\'s get acquainted.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: AppTheme.ffUbuntuLight,
                    ),
                  ),
                ),
                2.h,
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    text: 'My name is Lusi and I love active adventures!',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: AppTheme.ffUbuntuLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          0.dl,
          DemoAccount(),
          0.dl,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR + 5),
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                text: '',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: AppTheme.ffUbuntuLight,
                ),
                children: [
                  TextSpan(
                    text: 'To ',
                  ),
                  TextSpan(
                    text: 'walk',
                    style: TextStyle(
                      color: AppTheme.clYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' in parks and forests.',
                  ),
                ],
              ),
            ),
          ),
          2.h,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR + 5),
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                text: '',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: AppTheme.ffUbuntuLight,
                ),
                children: [
                  TextSpan(
                    text: 'To chase the ',
                  ),
                  TextSpan(
                    text: 'bike',
                    style: TextStyle(
                      color: AppTheme.clYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' with all my might..',
                  ),
                ],
              ),
            ),
          ),
          2.h,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR + 5),
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                text: '',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: AppTheme.ffUbuntuLight,
                ),
                children: [
                  TextSpan(
                    text: 'Hah, and of course, I just love ',
                  ),
                  TextSpan(
                    text: 'running',
                    style: TextStyle(
                      color: AppTheme.clYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' :)',
                  ),
                ],
              ),
            ),
          ),
          0.dl,
          0.dl,
          AppGestureButton(
            onTap: _doShelter,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.appLR + 5,
              ),
              color: AppTheme.clBackground,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          child: Image.asset(
                            'assets/***/***/rafi.jpg',
                            cacheHeight: 210,
                            cacheWidth: 210,
                          ),
                        ),
                      ),
                      4.h,
                      Text(
                        'Rafi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  20.w,
                  Column(
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          child: Image.asset(
                            'assets/***/***/conrad.jpg',
                            cacheHeight: 210,
                            cacheWidth: 210,
                          ),
                        ),
                      ),
                      4.h,
                      Text(
                        'Conrad',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  20.w,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: context.width * 0.4,
                        child: RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            text: '',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: AppTheme.ffUbuntuLight,
                            ),
                            children: [
                              TextSpan(
                                text: 'And I have two wonderful ',
                              ),
                              TextSpan(
                                text: 'dogs',
                                style: TextStyle(
                                  color: AppTheme.clYellow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      10.h,
                      Container(
                        height: 2,
                        width: 66,
                        color: AppTheme.clBlack,
                      ),
                      10.h,
                      Row(
                        children: [
                          SizedBox(
                            height: 22,
                            width: 22,
                            child: Image.asset(
                              'assets/***/***/doghopeorg.png',
                              cacheHeight: 66,
                              cacheWidth: 66,
                            ),
                          ),
                          10.w,
                          Text(
                            'Dog Shelter',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          0.dl,
          0.dl,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR + 5),
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                text: '',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: AppTheme.ffUbuntuLight,
                ),
                children: [
                  TextSpan(
                    text: 'Check out my ',
                  ),
                  TextSpan(
                    text: 'trails',
                    style: TextStyle(
                      color: AppTheme.clYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' with TrailCatch.',
                  ),
                ],
              ),
            ),
          ),
          ProfileGit(
            user: user,
            showStats: false,
            mpage: 18,
          ),
          20.h,
          0.hrr(height: 2),
          10.h,
          Center(
            child: AppSimpleButton(
              text: 'Join with Lusi',
              width: context.width * AppTheme.appBtnWidth,
              textColor: AppTheme.clYellow,
              onTry: () async {
                if (mounted) {
                  setState(() => _loading = true);
                }

                await authServ.signInDemo(1);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DemoAccount extends StatelessWidget {
  const DemoAccount({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    int sCount = 69;
    int sDistance = 724000;
    int sElevation = 4384;
    int sTime = 218601;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.appLR,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppTheme.clBlack,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  child: Image.asset(
                    'assets/***/luuuusi.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              12.w,
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      6.h,
                      Text(
                        'Lusi',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@lusiakasan',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.clText08,
                          height: 1,
                        ),
                      ),
                      10.h,
                    ],
                  ),
                ],
              ),
            ],
          ),
          10.h,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: context.width * 0.35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trails & Distance:',
                      style: TextStyle(
                        fontSize: 10,
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
                                '${'${fnNumCompact(sCount)} / '}${fnDistance(sDistance, compact: true)}',
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.clText,
                                ),
                              ),
                            ),
                            Text(
                              'D+ $sElevation',
                              style: TextStyle(
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
              SizedBox(
                width: context.width * 0.35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Time:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.clText08,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        fnTimeExt(sTime),
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.clText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Text(
                      'Latest 6 months',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.clText04,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InitPresent extends StatelessWidget {
  const InitPresent({
    super.key,
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Text('Text of des'),
    );
  }
}
