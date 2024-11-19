// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:trailcatch/constants.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/device_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class DevicesPolarSheet extends StatelessWidget {
  const DevicesPolarSheet({
    super.key,
  });

  Future<void> _doSyncTrails() async {
    AppRoute.goSheetBack();
    await deviceVM.connPolar();

    AppRoute.goTo('/devices_sync', args: {
      'deviceId': DeviceId.polar,
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isConnected = deviceVM.isPolar;
    String deviceStr = DeviceId.formatToStr(DeviceId.polar);

    String textStr = 'Connect with $deviceStr';
    if (isConnected) {
      textStr = 'Disconnect from $deviceStr';
    }

    return AppBottomScaffold(
      title: 'Polar',
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
                Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 5),
                  child: Container(
                    height: 62,
                    width: 140,
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Image.asset(
                      'assets/***/***/PolarLogo.png',
                      fit: BoxFit.fitWidth,
                      cacheHeight: 210,
                      cacheWidth: 459,
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Sync your Trails\nwith Polar',
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
              'Polar is a well-established brand in the sport watch market, known for pioneering heart rate monitoring and providing advanced fitness tracking technology. Their sport watches, like the Polar Vantage and Grit X series, are designed to support athletes with detailed performance insights, precise heart rate data, and personalized training guidance.\n\nWith a focus on science-backed data and athlete-friendly design, Polar sport watches are popular among both professional athletes and fitness enthusiasts looking to improve their performance and maintain a healthy training balance.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            0.dl,
            0.dl,
            AppGestureButton(
              onTry: () async {
                launchUrl(Uri.parse('https://www.polar.com/'));
              },
              child: Container(
                color: AppTheme.clBackground,
                child: const Center(
                  child: Text(
                    'Learn more about Polar',
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
                                await deviceVM.disconnPolar();
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
