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
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/pref_utils.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/buttons/widget_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({
    super.key,
    required this.canGoBack,
    required this.showPinDesc,
  });

  final bool canGoBack;
  final bool showPinDesc;

  @override
  PinScreenState createState() => PinScreenState();
}

class PinScreenState extends State<PinScreen> {
  late bool _loading;
  late bool _isOk;
  late bool _showPinDesc;

  @override
  void initState() {
    _loading = false;
    _isOk = true;
    _showPinDesc = widget.showPinDesc;

    scheduleMicrotask(() {
      if (!_showPinDesc) {
        _showPin();
      }
    });

    super.initState();
  }

  Future<void> _showPin() async {
    _isOk = await fnAskFaceId();

    if (mounted) {
      setState(() {});
    }

    if (_isOk) {
      fnPrefSaveLastFaceId();

      await userServ.fnUsersUpdate(faceid: 15);
      AppRoute.goBack(_isOk);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSimpleScaffold(
        title: 'Face ID & Passcode',
        loadingExt: _loading,
        onBack: () async {
          if (widget.canGoBack) {
            AppRoute.goBack(false);
          } else {
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
          }
        },
        actions: [
          if (!_showPinDesc)
            AppWidgetButton(
              onTap: () {
                AppRoute.showPopup(
                  [
                    AppPopupAction(
                      'Try Again',
                      color: AppTheme.clYellow,
                      () async {
                        _showPin();
                      },
                    ),
                    AppPopupAction(
                      'App Settings',
                      () async {
                        await fnAppSettings();
                      },
                    ),
                  ],
                );
              },
              child: const Icon(
                Icons.lock_reset_rounded,
                color: AppTheme.clText,
                size: 26,
              ),
            ),
        ],
        wBottom: _showPinDesc
            ? Column(
                children: [
                  AppSimpleButton(
                    onTap: () async {
                      AppRoute.showPopup(
                        [
                          AppPopupAction(
                            'Skip',
                            color: AppTheme.clRed,
                            () async {
                              setState(() {
                                _showPinDesc = false;
                              });

                              appVM.showPinDesc = false;

                              await userServ.fnUsersUpdate(faceid: -1);
                              appVM.notify();

                              setState(() {
                                _loading = true;
                              });

                              AppRoute.goBack();
                            },
                          ),
                        ],
                      );
                    },
                    width: context.width * AppTheme.appBtnWidth,
                    text: 'Skip',
                    textColor: AppTheme.clText,
                  ),
                  5.h,
                  AppSimpleButton(
                    onTap: () async {
                      setState(() {
                        _showPinDesc = false;
                      });

                      appVM.showPinDesc = false;

                      final isSupported = await fnIsFaceIdSupported();
                      if (!isSupported) {
                        AppRoute.goBack(true);
                        return;
                      }

                      setState(() {
                        _loading = true;
                      });

                      await _showPin();
                    },
                    width: context.width * AppTheme.appBtnWidth,
                    text: 'Set Up',
                    textColor: AppTheme.clYellow,
                    borderColor: AppTheme.clYellow,
                  ),
                ],
              )
            : Image.asset(
                'assets/***/app_icon.png',
                width: 100,
                height: 100,
                cacheHeight: 100,
                cacheWidth: 100,
              ),
        child: Column(
          children: [
            if (!_isOk && !_showPinDesc)
              SizedBox(
                height: context.height / 1.5,
                width: context.width / 1.5,
                child: const Center(
                  child: Text(
                    'Unable to verify your\nFace ID or Passcode',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                      color: AppTheme.clText07,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (_showPinDesc)
              Column(
                children: [
                  Container(
                    height: context.height / 1.5,
                    width: context.width,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.appLR * 2,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Please set up your\nFace ID or Passcode.',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          40.h,
                          Text(
                            'This will assist in safeguarding your personal data.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ));
  }
}
