// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/device_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/viewmodels/device_viewmodel.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<DeviceViewModel>();

    return AppSimpleScaffold(
      title: 'Devices',
      children: [
        10.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: GridView.count(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              for (var deviceId in [
                DeviceId.fit,
                ...DeviceId.all,
              ]) ...[
                LayoutBuilder(builder: (context, _) {
                  Widget deviceLogo = Container();
                  if (deviceId == DeviceId.garmin) {
                    deviceLogo = Container(
                      padding: const EdgeInsets.only(left: 0),
                      child: SizedBox(
                        height: 70,
                        width: 140,
                        child: Image.asset(
                          'assets/***/***/GarminLogo.png',
                          fit: BoxFit.fitWidth,
                          cacheHeight: 210,
                          cacheWidth: 330,
                        ),
                      ),
                    );
                  } else if (deviceId == DeviceId.suunto) {
                    deviceLogo = SizedBox(
                      height: 70,
                      width: 140,
                      child: Image.asset(
                        'assets/***/***/SuuntoLogo.png',
                        fit: BoxFit.fitWidth,
                        cacheHeight: 210,
                        cacheWidth: 459,
                      ),
                    );
                  } else if (deviceId == DeviceId.polar) {
                    deviceLogo = Container(
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
                    );
                  } else if (deviceId == DeviceId.fit) {
                    deviceLogo = Container(
                      margin: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Container(
                        height: 62,
                        width: 140,
                        color: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Center(
                          child: Text(
                            '*.FIT',
                            style: TextStyle(
                              fontFamily: AppTheme.ffUbuntuRegular,
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  bool isConnected = deviceVM.isDevice(deviceId);
                  String connStr = isConnected ? 'Connected' : 'Not connected';

                  String path = '/devices_';
                  if (deviceId == DeviceId.garmin) {
                    path += 'garmin';
                  } else if (deviceId == DeviceId.suunto) {
                    path += 'suunto';
                  } else if (deviceId == DeviceId.polar) {
                    path += 'polar';
                  } else if (deviceId == DeviceId.fit) {
                    path += 'fit';
                  }

                  return AppGestureButton(
                    onTap: () async {
                      AppRoute.goSheetTo(path);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.clBackground,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        border: Border.all(width: 2, color: AppTheme.clBlack),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          10.h,
                          deviceLogo,
                          15.h,
                          Text(
                            deviceId == DeviceId.fit
                                ? 'FIT file'
                                : DeviceId.formatToStr(deviceId),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            deviceId == DeviceId.fit ? 'Manually' : connStr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isConnected
                                  ? AppTheme.clYellow
                                  : AppTheme.clText05,
                            ),
                          ),
                          10.h,
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
