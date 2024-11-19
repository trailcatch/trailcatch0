// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trailcatch/constants.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/device_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class DevicesSuuntoSheet extends StatelessWidget {
  const DevicesSuuntoSheet({
    super.key,
  });

  Future<void> _doSyncTrails() async {
    AppRoute.goSheetBack();
    await deviceVM.connSuunto();

    AppRoute.goTo('/devices_sync', args: {
      'deviceId': DeviceId.suunto,
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isConnected = deviceVM.isSuunto;
    String deviceStr = DeviceId.formatToStr(DeviceId.suunto);

    String textStr = 'Connect with $deviceStr';
    if (isConnected) {
      textStr = 'Disconnect from $deviceStr';
    }

    return AppBottomScaffold(
      title: 'Suunto',
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
                    'assets/***/***/SuuntoLogo.png',
                    fit: BoxFit.fitWidth,
                    cacheHeight: 210,
                    cacheWidth: 459,
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Sync your Trails\nwith Suunto',
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
              'Suunto is a prominent brand in the sport watch industry, celebrated for producing durable and reliable timepieces designed for outdoor and endurance sports. Known for their robust craftsmanship, Suunto watches, such as the Suunto 9 and Suunto Vertical, are engineered to withstand extreme conditions, featuring long battery life, water resistance, and rugged designs.\n\nSuunto emphasizes precision and adventure-readiness, making their sport watches a preferred choice for outdoor enthusiasts and athletes seeking both reliability and comprehensive data for their pursuits.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            0.dl,
            0.dl,
            AppGestureButton(
              onTry: () async {
                launchUrl(Uri.parse('https://www.suunto.com/'));
              },
              child: Container(
                color: AppTheme.clBackground,
                child: const Center(
                  child: Text(
                    'Learn more about Suunto',
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
                                await deviceVM.disconnSuunto();
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
