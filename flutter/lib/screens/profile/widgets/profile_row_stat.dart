// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';

class ProfileRowStat extends StatefulWidget {
  const ProfileRowStat({
    super.key,
    this.count = 0,
    required this.distance,
    required this.elevation,
    required this.time,
    this.avgPace = 0,
    this.avgSpeed = 0,
    this.showType = true,
    this.single = false,
    this.typeStr,
    this.avgAnimate = false,
    this.hideAvg = false,
    this.sepTrails = false,
  });

  final int count;
  final int distance;
  final int elevation;
  final int time;
  final int avgPace;
  final int avgSpeed;
  final bool showType;
  final bool single;
  final String? typeStr;
  final bool avgAnimate;
  final bool hideAvg;
  final bool sepTrails;

  @override
  State<ProfileRowStat> createState() => _ProfileRowStatState();
}

class _ProfileRowStatState extends State<ProfileRowStat> {
  bool _isBike = false;
  late bool _isPace;

  @override
  void initState() {
    _isBike = widget.typeStr?.startsWith('Bike') ?? false;
    _isPace = widget.typeStr == null || !_isBike;

    if (!_isBike && widget.avgAnimate) {
      _isPace = !_isPace;

      Future.delayed(250.mlsec, () {
        if (mounted) {
          setState(() {
            _isPace = !_isPace;
          });
        }
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String avgPaceValue = fnTimeExt(
      fnParsePaceSec(widget.avgPace, appVM.settings.msrunit),
      zero1th: false,
    );
    String avgSpeedValue = fnTimeExt(
      fnParseSpeedSec(widget.avgSpeed, appVM.settings.msrunit),
      zero1th: false,
    );

    return Container(
      color: AppTheme.clBackground,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
      width: context.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.sepTrails) ...[
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trails: ',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.clText08,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${widget.count}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            15.h,
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            5.w,
          ],
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.single || widget.sepTrails
                      ? 'Distance, ${fnDistUnit()}:'
                      : 'Trails & Distance:',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.clText08,
                  ),
                  textAlign: TextAlign.start,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${widget.single || widget.sepTrails ? '' : '${widget.count} / '}${fnDistance(widget.distance)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'D+ ${widget.elevation}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          5.w,
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: !widget.hideAvg
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.end,
              mainAxisAlignment: !widget.hideAvg
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.end,
              children: [
                const Text(
                  'Time:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.clText08,
                  ),
                  textAlign: TextAlign.end,
                ),
                SizedBox(
                  width: widget.hideAvg ? null : context.width * 0.25,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      fnTimeExt(widget.time),
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign:
                          widget.hideAvg ? TextAlign.end : TextAlign.center,
                    ),
                  ),
                ),
                15.h,
              ],
            ),
          ),
          5.w,
          if (!widget.hideAvg)
            Expanded(
              flex: 1,
              child: AppGestureButton(
                onTap: () {
                  if (widget.typeStr == null) return;

                  if (_isBike) return;

                  setState(() {
                    _isPace = !_isPace;
                  });
                },
                child: Container(
                  height: 65,
                  color: AppTheme.clBackground,
                  child: Column(
                    children: [
                      if (widget.typeStr != null)
                        Stack(
                          children: [
                            AnimatedOpacity(
                              opacity: _isPace ? 1.0 : 0.0,
                              duration: 500.mlsec,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Avg Pace',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.clText08,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        avgPaceValue,
                                        style: const TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: _isPace ? 0.0 : 1.0,
                              duration: 250.mlsec,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Avg Speed',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.clText08,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        avgSpeedValue,
                                        style: const TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      if (widget.typeStr != null && widget.showType)
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            widget.typeStr!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
