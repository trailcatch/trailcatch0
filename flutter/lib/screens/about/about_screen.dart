// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/field_button.dart';
import 'package:trailcatch/widgets/header.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSimpleScaffold(
      title: 'About',
      children: [
        const AppHeader(title: 'TrailCatch', margin: EdgeInsets.zero),
        0.dl,
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'App Version:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.clText08,
              ),
              textAlign: TextAlign.center,
            ),
            6.h,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                50.w,
                Text(
                  appVM.appVersion,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                    color: AppTheme.clYellow,
                  ),
                ),
                AppGestureButton(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.clBlack,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Icon(
                      Icons.store_mall_directory_outlined,
                    ),
                  ),
                  onTry: () async {
                    launchUrl(
                      Uri.parse('https://apps.apple.com/app/id6535756449'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ],
            )
          ],
        ),
        const AppHeader(title: 'Documents'),
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            text: 'Terms and Conditions',
            onTry: () async {
              launchUrl(Uri.parse('https://trailcatch.com/terms'));
            },
          ),
        ),
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            text: 'Privacy Policy',
            onTry: () async {
              launchUrl(Uri.parse('https://trailcatch.com/policy'));
            },
          ),
        ),
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            text: 'FAQ',
            onTry: () async {
              launchUrl(Uri.parse('https://trailcatch.com/faq'));
            },
          ),
        ),
        0.dl,
        const AppHeader(title: 'Dogs'),
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            text: 'Dog Breeds',
            onTap: () {
              AppRoute.goTo('/profile_dogs_breed', args: {
                'justView': true,
              });
            },
          ),
        ),
        0.dl,
        const AppHeader(title: 'Support'),
        0.dl,
        AboutSupport(),
        0.dl,
        const AppHeader(title: 'The Team'),
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: Image.asset('assets/***/team_me.jpg'),
                    ),
                  ),
                  10.h,
                  const Text(
                    'Ihar Petushkou',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Founder',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.clText08,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              AppGestureButton(
                onTap: () {
                  AppRoute.goSheetTo('/about_lusi');
                },
                child: Container(
                  color: AppTheme.clBackground,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          child: Image.asset(
                            'assets/***/luuuusi.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      10.h,
                      const Text(
                        'Lusi',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Chief Creative Officer',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      15.h,
                      Container(
                        height: 2,
                        width: 66,
                        color: AppTheme.clBlack,
                      ),
                      10.h,
                      Text(
                        'The Message',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.clYellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AboutSupport extends StatelessWidget {
  const AboutSupport({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            title: 'Email',
            text: 'team@trailcatch.com',
            onTry: () async {
              var url = Uri.parse(
                'mailto:team@trailcatch.com',
              );
              await launchUrl(url);
            },
          ),
        ),
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            title: 'X',
            text: 'x.com/trailcatch',
            onTry: () async {
              var url = Uri.parse('https://x.com/trailcatch');
              await launchUrl(url);
            },
          ),
        ),
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            title: 'Facebook',
            text: 'facebook.com/trailcatchcom',
            onTry: () async {
              var url = Uri.parse('https://www.facebook.com/trailcatchcom');
              await launchUrl(url);
            },
          ),
        ),
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            title: 'Reddit',
            text: 'reddit.com/r/TrailCatch',
            onTry: () async {
              var url = Uri.parse('https://reddit.com/r/TrailCatch');
              await launchUrl(url);
            },
          ),
        ),
      ],
    );
  }
}
