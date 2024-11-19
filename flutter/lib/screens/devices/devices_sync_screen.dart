// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import 'package:trailcatch/constants.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/device_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/viewmodels/device_viewmodel.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class DevicesSyncScreen extends StatefulWidget {
  const DevicesSyncScreen({
    super.key,
    required this.deviceId,
  });

  final int deviceId;

  @override
  State<DevicesSyncScreen> createState() => _DevicesSyncScreenState();
}

class _DevicesSyncScreenState extends State<DevicesSyncScreen> {
  late bool _loading;
  late bool _finished;

  late bool _loadingTrails;

  late bool _allTrailsCountLoading;
  late int _allTrailsCount;

  @override
  void initState() {
    _loading = true;
    _finished = false;
    _loadingTrails = false;

    _allTrailsCountLoading = true;
    _allTrailsCount = 0;

    deviceVM.clearSyncedCounts();

    scheduleMicrotask(_doSync);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    context.watch<DeviceViewModel>();

    super.didChangeDependencies();
  }

  Future<void> _doSync() async {
    await trailVM.reFetchMyTrails(
      syncDate: const SyncDate(),
      deviceId: widget.deviceId,
    );

    setState(() {
      _allTrailsCount = trailVM.myTrailsExt.fold(
          0, (acc, it) => acc + (it.trail.deviceId == widget.deviceId ? 1 : 0));

      _allTrailsCountLoading = false;
    });

    await deviceVM.reSyncDeviceTrails(
      syncDate: const SyncDate(),
      deviceId: widget.deviceId,
    );

    await trailVM.reFetchMyTrails(
      syncDate: const SyncDate(
        limit: cstFirstLoadItemCount,
      ),
    );

    trailVM.notify();

    if (mounted) {
      setState(() {
        _finished = true;
      });

      if (deviceVM.stopTrailsSync) {
        await Future.delayed(1000.mlsec);

        deviceVM.stopTrailsSync = false;
        AppRoute.goBack();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String deviceStr = DeviceId.formatToStr(widget.deviceId);

    Widget logo = Container();

    if (widget.deviceId == DeviceId.garmin) {
      logo = SizedBox(
        height: 70,
        width: 140,
        child: Image.asset(
          'assets/***/***/GarminLogo.png',
          fit: BoxFit.fitWidth,
          cacheHeight: 210,
          cacheWidth: 330,
        ),
      );
    } else if (widget.deviceId == DeviceId.suunto) {
      logo = SizedBox(
        height: 70,
        width: 140,
        child: Image.asset(
          'assets/***/***/SuuntoLogo.png',
          fit: BoxFit.fitWidth,
          cacheHeight: 210,
          cacheWidth: 459,
        ),
      );
    } else if (widget.deviceId == DeviceId.polar) {
      logo = Container(
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
    }

    _loadingTrails = deviceVM.syncedTrailsCount != null;

    Widget wBottom = Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 20),
      child: LoadingIndicator(
        indicatorType: Indicator.ballTrianglePathColoredFilled,
        colors: [
          AppTheme.clText,
          if (_loadingTrails) AppTheme.clYellow,
          if (_loadingTrails) AppTheme.clRed,
        ],
        backgroundColor: AppTheme.clBackground,
        pathBackgroundColor: AppTheme.clBackground,
      ),
    );

    if (_finished && !deviceVM.stopTrailsSync) {
      wBottom = wBottom = Column(
        children: [
          0.hrr(height: 2),
          10.h,
          AppSimpleButton(
            width: context.width * AppTheme.appBtnWidth,
            text: 'Finish',
            textColor: AppTheme.clYellow,
            onTry: AppRoute.goBack,
          ),
        ],
      );
    }

    return AppSimpleScaffold(
      title: 'Syncing $deviceStr',
      wBottom:
          (_loading || _finished) && !deviceVM.stopTrailsSync ? wBottom : null,
      onBack: () async {
        if (!_finished) {
          await AppRoute.showPopup(
            [
              AppPopupAction(
                'Stop Syncing $deviceStr',
                color: AppTheme.clRed,
                () async {
                  deviceVM.stopTrailsSync = true;
                  AppRoute.goBack();
                },
              ),
            ],
          );
        } else {
          AppRoute.goBack();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            40.h,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 0),
                  child: logo,
                ),
                SizedBox(
                  width: 130,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Trails',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.clText08,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 50,
                        child: Text(
                          _allTrailsCountLoading
                              ? '-'
                              : fnNumCompact(_allTrailsCount +
                                  (deviceVM.syncedTrails ?? 0)),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 45,
                            color: AppTheme.clText,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            30.h,
            10.hrr(height: 2),
            20.h,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'To Sync Trails',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.clText08,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      4.h,
                      Container(
                        height: 70,
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          !_loadingTrails
                              ? '-'
                              : fnNumCompact(deviceVM.syncedTrailsCount ?? 0),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 45,
                            color: AppTheme.clText,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Synced Trails',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.clText08,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      4.h,
                      Container(
                        height: 70,
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          !_loadingTrails
                              ? '-'
                              : fnNumCompact(deviceVM.syncedTrails ?? 0),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 45,
                            color: deviceVM.syncedTrails != 0
                                ? AppTheme.clYellow
                                : AppTheme.clText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
