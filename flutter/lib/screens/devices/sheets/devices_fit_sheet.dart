// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:trailcatch/services/crash_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/device_utils.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class DevicesFitSheet extends StatefulWidget {
  const DevicesFitSheet({
    super.key,
  });

  @override
  State<DevicesFitSheet> createState() => _DevicesFitSheetState();
}

class _DevicesFitSheetState extends State<DevicesFitSheet> {
  late bool _loading;
  late bool _stopped;
  late bool _locked;

  @override
  void initState() {
    _loading = false;
    _stopped = false;
    _locked = false;

    super.initState();
  }

  Future<void> _doParseFIT() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['.fit'],
    );

    if (result != null && result.files.single.path != null) {
      final File file = File(result.files.single.path!);
      final fstat = file.statSync();
      if (fstat.size > 2097152) return; // 2 mb

      if (mounted) {
        setState(() => _loading = true);
      }

      TrailModel? trail = await fnParseFitData(
        bytes: file.readAsBytesSync(),
        fitFile: true,
      );

      if (_stopped) return;

      if (trail != null) {
        final trailId0 = await trailServ.fnTrailsExists(
          deviceDataId: trail.deviceDataId,
        );
        if (trailId0 != null) {
          AppRoute.goSheetTo('/devices_trail_exists', args: {
            'trailId': trailId0,
          });

          return;
        }

        final dbtrail = await trailServ.fnTrailsInsert(
          type: trail.type,
          datetimeAt: trail.datetimeAt,
          distance: trail.distance,
          elevation: trail.elevation,
          time: trail.time,
          //
          avgPace: trail.avgPace,
          avgSpeed: trail.avgSpeed,
          //
          dogsIds: trail.dogsIds,
          //
          deviceId: trail.deviceId,
          deviceDataId: trail.deviceDataId,
          deviceData: trail.deviceData?.toJson(),
          deviceGeopoints: LatLng.toPGMultiPointSRID(trail.deviceGeopoints),
        );

        if (_stopped) return;

        if (dbtrail != null) {
          final trailExt = TrailExtModel.fromTrail(dbtrail);
          trailVM.myTrailsExt.add(trailExt);
          fnSortTrailsDateDesc(trailVM.myTrailsExt);

          if (_stopped) return;

          trailVM.notify();
          AppRoute.goSheetBack();

          await Future.delayed(250.mlsec);

          final isRefresh = await AppRoute.goTo(
            '/trail_card',
            args: {
              'trailExt': trailExt,
            },
          );

          AppRoute.goBack(isRefresh);
        }
      }
    }

    if (_loading && mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomScaffold(
      title: 'Trail & FIT',
      onBack: () async {
        if (_loading) {
          await AppRoute.showPopup(
            [
              AppPopupAction(
                'Stop & Go Back',
                color: AppTheme.clRed,
                () async {
                  _stopped = true;

                  AppRoute.goBack();
                },
              ),
            ],
          );
        }
      },
      child: Container(
        width: context.width,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
        child: Stack(
          children: [
            Opacity(
              opacity: _loading ? 0.2 : 1.0,
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
                        child: Container(
                          padding: const EdgeInsets.only(left: 35, top: 10),
                          child: Text(
                            '*.FIT',
                            style: TextStyle(
                              fontFamily: AppTheme.ffUbuntuRegular,
                              fontWeight: FontWeight.bold,
                              fontSize: 34,
                            ),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Build your Trail\nwith FIT file',
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
                    'A FIT file (Flexible and Interoperable Data Transfer file) is a data format developed by Garmin and commonly used by sport watches to store and transfer fitness and activity data. This file format is designed to be compact and efficient, making it ideal for recording detailed workout metrics such as GPS coordinates, heart rate, speed, elevation, and distance.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  0.dl,
                  0.dl,
                  AppGestureButton(
                    onTry: () async {
                      launchUrl(
                        Uri.parse('https://developer.garmin.com/fit/protocol/'),
                      );
                    },
                    child: Container(
                      color: AppTheme.clBackground,
                      child: const Center(
                        child: Text(
                          'Learn more about FIT file',
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
                  Center(
                    child: AppSimpleButton(
                      text: 'Upload FIT file',
                      width: context.width * AppTheme.appBtnWidth,
                      borderColor: AppTheme.clYellow,
                      textColor: AppTheme.clYellow,
                      fontWeight: FontWeight.normal,
                      onTry: () async {
                        if (fnIsDemo(silence: false)) return;

                        if (_locked) return;
                        _locked = true;

                        try {
                          await _doParseFIT();
                        } on Error catch (error, stack) {
                          CrashService.recordFitError(error, stack);
                          AppRoute.goSheetTo('/devices_fit_error');
                        } catch (error) {
                          AppRoute.goSheetTo('/devices_fit_error');
                        }

                        if (mounted) {
                          setState(() {
                            _loading = false;
                            _stopped = false;
                            _locked = false;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_loading)
              Center(
                child: Container(
                  height: 110,
                  margin: const EdgeInsets.only(top: 110),
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballTrianglePathColoredFilled,
                    colors: [
                      AppTheme.clText,
                      AppTheme.clYellow,
                      AppTheme.clRed,
                    ],
                    backgroundColor: AppTheme.clTransparent,
                    pathBackgroundColor: AppTheme.clTransparent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
