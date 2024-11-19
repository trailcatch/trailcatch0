// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trailcatch/utils/pref_utils.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';
import 'package:trailcatch/widgets/text.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  String _lastLogin = '';

  @override
  void initState() {
    appVM.isSingingAccount = false;

    fnPrefGetLastLogin().then((value) {
      setState(() {
        _lastLogin = value ?? '';
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String? wLastK;
    String? wLastDate;

    Widget wLastLogin = Container();
    if (_lastLogin.isNotEmpty) {
      wLastK = _lastLogin.split(',').first;
      wLastDate = _lastLogin.split(',').last;

      wLastLogin = Container(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Last login:  ${DateTime.parse(wLastDate).toMonthYear(isY2: true)}',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    bool isLastApple = wLastK == 'apple';
    bool isLastGoogle = wLastK == 'google';
    bool isLastFacebook = wLastK == 'facebook';
    bool isLastX = wLastK == 'twitter';
    bool isLastGitHub = wLastK == 'github';
    bool isLastDiscord = wLastK == 'discord';

    Widget wApple = Column(
      children: [
        Stack(
          children: [
            AppSimpleButton(
              text: '${isLastApple ? 'Continue' : 'Join'} with Apple',
              width: context.width * AppTheme.appBtnWidth,
              borderColor: isLastApple ? AppTheme.clYellow : null,
              textColor: isLastApple ? AppTheme.clYellow : null,
              onTry: () async {
                await appVM.reAppleCreds();

                setState(() => appVM.isSingingAccount = true);
                try {
                  await authServ.signInWithApple();
                } catch (err) {
                  setState(() => appVM.isSingingAccount = false);
                  rethrow;
                }
              },
            ),
            Positioned(
              top: 9,
              left: 8,
              child: Image.asset(
                'assets/***/***/apple_icon.png',
                height: 24,
                width: 24,
                color: Colors.white,
              ),
            ),
          ],
        ),
        if (isLastApple) wLastLogin,
      ],
    );

    Widget wGoogle = Column(
      children: [
        Stack(
          children: [
            AppSimpleButton(
              text: '${isLastGoogle ? 'Continue' : 'Join'} with Google',
              width: context.width * AppTheme.appBtnWidth,
              borderColor: isLastGoogle ? AppTheme.clYellow : null,
              textColor: isLastGoogle ? AppTheme.clYellow : null,
              onTry: () async {
                setState(() => appVM.isSingingAccount = true);
                try {
                  await authServ.signInWithGoogle();
                } catch (err) {
                  setState(() => appVM.isSingingAccount = false);
                  rethrow;
                }
              },
            ),
            Positioned(
              top: 14,
              left: 11,
              child: Image.asset(
                'assets/***/***/google_icon.png',
                height: 18,
                width: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        if (isLastGoogle) wLastLogin,
      ],
    );

    Widget wFacebook = Column(
      children: [
        Stack(
          children: [
            AppSimpleButton(
              text: '${isLastFacebook ? 'Continue' : 'Join'} with Facebook',
              width: context.width * AppTheme.appBtnWidth,
              borderColor: isLastFacebook ? AppTheme.clYellow : null,
              textColor: isLastFacebook ? AppTheme.clYellow : null,
              onTry: () async {
                setState(() => appVM.isSingingAccount = true);
                try {
                  await authServ.signInWithFacebook();
                } catch (err) {
                  setState(() => appVM.isSingingAccount = false);
                  rethrow;
                }
              },
            ),
            Positioned(
              top: 12,
              left: 10,
              child: Image.asset(
                'assets/***/***/facebook_icon.png',
                height: 20,
                width: 20,
              ),
            ),
          ],
        ),
        if (isLastFacebook) wLastLogin,
      ],
    );

    Widget wX = Column(
      children: [
        Stack(
          children: [
            AppSimpleButton(
              text: '${isLastX ? 'Continue' : 'Join'} with X',
              height: 36,
              width: context.width * AppTheme.appBtnWidth,
              borderColor: isLastX ? AppTheme.clYellow : null,
              textColor: isLastX ? AppTheme.clYellow : null,
              onTry: () async {
                setState(() => appVM.isSingingAccount = true);
                try {
                  await authServ.signInWithTwitter();
                } catch (err) {
                  setState(() => appVM.isSingingAccount = false);
                  rethrow;
                }
              },
            ),
            Positioned(
              top: 14,
              left: 12,
              child: Image.asset(
                'assets/***/***/twitter_icon.png',
                height: 16,
                width: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        if (isLastX) wLastLogin,
      ],
    );

    Widget wGitHub = Column(
      children: [
        Stack(
          children: [
            AppSimpleButton(
              text: '${isLastGitHub ? 'Continue' : 'Join'} with GitHub',
              width: context.width * AppTheme.appBtnWidth,
              borderColor: isLastGitHub ? AppTheme.clYellow : null,
              textColor: isLastGitHub ? AppTheme.clYellow : null,
              onTry: () async {
                setState(() => appVM.isSingingAccount = true);
                try {
                  await authServ.signInWithGitHub();
                } catch (err) {
                  setState(() => appVM.isSingingAccount = false);
                  rethrow;
                }
              },
            ),
            Positioned(
              top: 12,
              left: 10,
              child: Image.asset(
                'assets/***/***/github_icon.png',
                height: 20,
                width: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        if (isLastGitHub) wLastLogin,
      ],
    );

    Widget wDiscord = Column(
      children: [
        Stack(
          children: [
            AppSimpleButton(
              text: '${isLastDiscord ? 'Continue' : 'Join'} with Discord',
              width: context.width * AppTheme.appBtnWidth,
              borderColor: isLastDiscord ? AppTheme.clYellow : null,
              textColor: isLastDiscord ? AppTheme.clYellow : null,
              onTap: () async {
                setState(() => appVM.isSingingAccount = true);
                try {
                  await authServ.signInWithDiscord();
                } catch (err) {
                  setState(() => appVM.isSingingAccount = false);
                  rethrow;
                }
              },
            ),
            Positioned(
              top: 12,
              left: 10,
              child: Image.asset(
                'assets/***/***/discord_icon.png',
                height: 20,
                width: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        if (isLastDiscord) wLastLogin,
      ],
    );

    Widget? wFirst;
    final wList = [wApple, wGoogle, wFacebook, wX, wGitHub, wDiscord];
    if (isLastApple) {
      wFirst = wList.removeAt(0);
    } else if (isLastGoogle) {
      wFirst = wList.removeAt(1);
    } else if (isLastFacebook) {
      wFirst = wList.removeAt(2);
    } else if (isLastX) {
      wFirst = wList.removeAt(3);
    } else if (isLastGitHub) {
      wFirst = wList.removeAt(4);
    } else if (isLastDiscord) {
      wFirst = wList.removeAt(5);
    }

    return AppSimpleScaffold(
      title: 'Join TrailCatch',
      loadingExt: appVM.isSingingAccount,
      wBottom: Column(
        children: [
          5.h,
          15.hrr(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.center,
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                text: 'By continuing, you agree to ',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: AppTheme.ffUbuntuLight,
                ),
                children: [
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse('https://trailcatch.com/terms'));
                      },
                  ),
                  TextSpan(
                    text: ' and confirm that you have read ',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  TextSpan(
                    text: 'Privacy Policy.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse('https://trailcatch.com/policy'));
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      children: [
        10.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: AppText.tsRegular(
            'Join TrailCatch effortlessly with your favorite social account.',
          ),
        ),
        10.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: AppText.tsRegular(
            'No emails, no forgotten passwords, no stolen credentials.',
          ),
        ),
        15.hrr(height: 3),
        if (wFirst != null) ...[
          wFirst,
          30.h,
        ],
        for (var w in wList) ...[
          w,
          if (wList.last != w) 20.h,
        ],
      ],
    );
  }
}
