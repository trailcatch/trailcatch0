// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';

class AppTCID extends StatelessWidget {
  const AppTCID({
    super.key,
    required this.trail,
    this.height,
    this.labelColor,
    this.leftColor,
    this.textColor,
    this.borderColor,
    this.borderWidth,
    this.leftTxt,
  });

  final TrailModel trail;
  final double? height;
  final Color? labelColor;
  final Color? leftColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderWidth;
  final String? leftTxt;

  @override
  Widget build(BuildContext context) {
    if (trail.isEmpt) {
      return Container(
        color: AppTheme.clBackground,
        height: height ?? 80,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 90,
            height: 110,
          ),
        ),
      );
    }

    Color? labelColor0;
    Color? leftColor0;
    Color? textColor0;
    Color? borderColor0;
    double? borderWidth0;
    String? leftTxt0 = leftTxt;

    if (trail.notPub) {
      labelColor0 = labelColor ?? AppTheme.clText04;
      leftColor0 = leftColor ?? AppTheme.clText04;
      textColor0 = textColor ?? AppTheme.clText07;
      borderColor0 = borderColor ?? AppTheme.clText01;
      leftTxt0 = '[+++]';
    } else if (trail.inTrash) {
      labelColor0 = labelColor ?? AppTheme.clRed;
      leftColor0 = leftColor ?? AppTheme.clRed;
      textColor0 = textColor ?? AppTheme.clText07;
      borderColor0 = borderColor ?? AppTheme.clRed;
      leftTxt0 = 'Trash';
    } else {
      labelColor0 = labelColor ?? AppTheme.clText;
      leftColor0 = leftColor ?? AppTheme.clText;
      textColor0 = textColor ?? AppTheme.clText;
      borderColor0 = borderColor ?? AppTheme.clText04;
    }

    borderWidth0 = borderWidth ?? 1;

    final String avgPaceValue = fnTimeExt(
      fnParsePaceSec(trail.avgPace, appVM.settings.msrunit),
      zero1th: false,
    );

    final String avgSpeedValue = fnTimeExt(
      fnParseSpeedSec(trail.avgSpeed, appVM.settings.msrunit),
      zero1th: false,
    );

    return Container(
      color: AppTheme.clBackground,
      height: height ?? 80,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 90,
          height: 110,
          child: Stack(
            children: [
              Positioned(
                top: 8,
                bottom: 8,
                left: 5,
                right: 5,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: borderWidth0,
                      color: borderColor0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      10.h,
                      Center(
                        child: SizedBox(
                          width: 65,
                          height: 25,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              fnDistance(trail.distance),
                              style: TextStyle(
                                fontSize: 20,
                                letterSpacing: 0.6,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppTheme.ffUbuntuRegular,
                                color: textColor0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      1.h,
                      Center(
                        child: SizedBox(
                          width: 65,
                          height: 22,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              fnTimeExt(trail.time),
                              style: TextStyle(
                                fontSize: 16,
                                letterSpacing: 0.6,
                                height: 1.3,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppTheme.ffUbuntuRegular,
                                color: textColor0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      1.h,
                      Center(
                        child: SizedBox(
                          width: 65,
                          height: 22,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              trail.type == TrailType.bike
                                  ? avgSpeedValue
                                  : avgPaceValue,
                              style: TextStyle(
                                fontSize: 14,
                                letterSpacing: 0.6,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppTheme.ffUbuntuRegular,
                                color: textColor0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      5.h,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 15,
                right: 15,
                child: Container(
                  color: AppTheme.clBlack,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    trail.datetimeAt.toTcidDate(),
                    style: TextStyle(
                      fontSize: 11,
                      color: labelColor0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (leftTxt0 != null)
                Positioned(
                  top: 25,
                  left: -2,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Container(
                      height: 16,
                      color: AppTheme.clBlack,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        leftTxt0,
                        style: TextStyle(
                          fontSize: 10,
                          color: leftColor0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 15,
                right: 15,
                child: Container(
                  height: 17,
                  color: AppTheme.clBlack,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        TrailType.formatTypeToIcon(trail.type),
                        size: 13,
                        color: labelColor0,
                      ),
                      if (trail.dogsIds.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              '  +  ',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: labelColor0,
                              ),
                            ),
                            2.w,
                            Icon(
                              Icons.pets,
                              size: 13,
                              color: labelColor0,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
