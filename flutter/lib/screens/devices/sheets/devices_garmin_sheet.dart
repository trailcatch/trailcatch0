// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trailcatch/constants.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/device_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class DevicesGarminSheet extends StatelessWidget {
  const DevicesGarminSheet({
    super.key,
  });

  Future<void> _doSyncTrails() async {
    AppRoute.goSheetBack();
    await deviceVM.connGarmin();

    AppRoute.goTo('/devices_sync', args: {
      'deviceId': DeviceId.garmin,
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isConnected = deviceVM.isGarmin;
    String deviceStr = DeviceId.formatToStr(DeviceId.garmin);

    String textStr = 'Connect with $deviceStr';
    if (isConnected) {
      textStr = 'Disconnect from $deviceStr';
    }

    return AppBottomScaffold(
      title: 'Garmin',
      child: Container(
        width: context.width,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            10.h,
            Row(
              children: [
                SizedBox(
                  height: 70,
                  width: 140,
                  child: Image.asset(
                    'assets/***/***/GarminLogo.png',
                    fit: BoxFit.fitWidth,
                    cacheHeight: 210,
                    cacheWidth: 330,
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Sync your Trails\nwith Garmin',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],
            ),
            0.dl,
            0.dl,
            const Text(
              'Garmin is a leading name in the world of sport watches, recognized for producing advanced, feature-rich wearables designed to support athletes and fitness enthusiasts.\n\nGarmin is renowned for its sport watches, offering precise GPS tracking, advanced fitness metrics, and rugged durability. Popular models like the Forerunner and Fenix series are packed with features such as heart rate monitoring, VO2 max analysis, and multisport tracking. These watches are ideal for athletes, providing comprehensive data to optimize performance and support outdoor adventures.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            0.dl,
            0.dl,
            AppGestureButton(
              onTry: () async {
                launchUrl(Uri.parse('https://www.garmin.com/'));
              },
              child: Container(
                color: AppTheme.clBackground,
                child: const Center(
                  child: Text(
                    'Learn more about Garmin',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: AppTheme.clBlue08,
                    ),
                  ),
                ),
              ),
            ),
            0.dl,
            if (isConnected) ...[
              Center(
                child: AppSimpleButton(
                  text: 'Sync All Trails',
                  width: context.width * AppTheme.appBtnWidth,
                  onTap: _doSyncTrails,
                ),
              ),
              10.hrr(
                height: 2,
                color: AppTheme.clBlack,
                padLR: context.width * 0.3,
              ),
            ],
            Center(
              child: Column(
                children: [
                  AppSimpleButton(
                    text: textStr,
                    width: context.width * AppTheme.appBtnWidth,
                    borderColor:
                        isConnected ? AppTheme.clRed : AppTheme.clYellow,
                    textColor: isConnected ? AppTheme.clRed : AppTheme.clYellow,
                    fontWeight:
                        isConnected ? FontWeight.bold : FontWeight.normal,
                    enable: false,
                    onTry: () async {
                      if (isConnected) {
                        AppRoute.showPopup(
                          [
                            AppPopupAction(
                              textStr,
                              color: AppTheme.clRed,
                              () async {
                                await deviceVM.disconnGarmin();
                                AppRoute.goSheetBack();
                              },
                            ),
                          ],
                        );
                      } else {
                        _doSyncTrails();
                      }
                    },
                  ),
                  Text(
                    cstAvlShortly,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.clText05,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
