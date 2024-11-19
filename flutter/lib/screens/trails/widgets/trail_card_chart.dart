// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/device_utils.dart';
import 'package:trailcatch/widgets/text.dart';

class TrailCardChart extends StatelessWidget {
  const TrailCardChart({
    super.key,
    required this.trailExt,
  });

  final TrailExtModel trailExt;

  @override
  Widget build(BuildContext context) {
    final bool isSpeed = trailExt.isBike;

    String label1 = fnDistUnit();
    String label2 = isSpeed
        ? TrailGraphData.formatKeyToStr(TrailGraphData.kSpeeds)
        : TrailGraphData.formatKeyToStr(TrailGraphData.kPaces);
    label2 = label2.toLowerCase();

    List<int> graphDataVal = [];

    if (trailExt.trail.deviceData != null) {
      List<int> distancesAv = List<int>.from(fnBuildAdaptiv(
        trailExt.trail.deviceData!.distances,
        appVM.settings.msrunit,
      ));

      List<int> pacesAv = List<int>.from(fnBuildAdaptiv(
        trailExt.trail.deviceData!.paces,
        appVM.settings.msrunit,
        avg: true,
      ));

      List<int> speedsAv = List<int>.from(fnBuildAdaptiv(
        trailExt.trail.deviceData!.speeds,
        appVM.settings.msrunit,
        avg: true,
      ));

      List<int>? inxs;
      if (distancesAv.length > 10) {
        inxs = fnGenAdaptivLimit(pacesAv.length);
      }

      if (inxs != null) {
        distancesAv = fnFilterAdaptivLimit(distancesAv, inxs);
        pacesAv = fnFilterAdaptivLimit(pacesAv, inxs);
        speedsAv = fnFilterAdaptivLimit(speedsAv, inxs);
      }

      if (isSpeed) {
        graphDataVal = speedsAv;
      } else {
        graphDataVal = pacesAv;
      }
    }

    if (graphDataVal.isEmpty) {
      graphDataVal = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    }

    return SizedBox(
      width: context.width,
      height: 130,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
        child: Stack(
          children: [
            Container(
              width: context.width,
              decoration: BoxDecoration(
                color: AppTheme.clBlack02,
                border: Border.all(width: 1, color: AppTheme.clBlack),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 6, bottom: 7, right: 8),
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 0,
                      bottom: 0,
                      left: 40,
                      right: 10,
                    ),
                    child: TrailCardChartCanvas(
                      graphDataVal: graphDataVal,
                      isSpeed: isSpeed,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 10,
                    child: Text(
                      label1,
                      style: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 10,
                    child: Text(
                      label2,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: AppTheme.clYellow,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TrailCardChartCanvas extends StatelessWidget {
  const TrailCardChartCanvas({
    super.key,
    required this.graphDataVal,
    required this.isSpeed,
  });

  final List<int> graphDataVal;
  final bool isSpeed;

  @override
  Widget build(BuildContext context) {
    List<FlSpot> dataVal = [const FlSpot(0, 0)];
    graphDataVal.asMap().forEach((inx, griVal) {
      dataVal.add(FlSpot(
        inx + 1,
        griVal + 0.0,
      ));
    });

    final List<int> maxYc = List<int>.from(graphDataVal);
    maxYc.sort();

    return LineChart(
      duration: const Duration(seconds: 1),
      LineChartData(
        lineTouchData: const LineTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          verticalInterval: 1,
          drawHorizontalLine: false,
          getDrawingVerticalLine: (value) {
            return const FlLine(
              color: AppTheme.clText2,
              strokeWidth: 0.4,
              dashArray: [2, 8],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 20,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value == 0) return AppText.tsRegular('');
                if (value == meta.max) return const Text('');

                double val0 = 0.0;
                for (var it in dataVal) {
                  if (it.x == value) {
                    val0 = it.y;
                    break;
                  }
                }

                String val0Str = val0.toStringAsFixed(0);
                if (isSpeed) {
                  val0Str = fnTimeExt(
                    fnParseSpeedSec(val0.toInt(), appVM.settings.msrunit),
                    zero1th: false,
                  );
                } else {
                  val0Str = fnTimeExt(
                    fnParsePaceSec(val0.toInt(), appVM.settings.msrunit),
                    zero1th: false,
                  );
                }

                bool isOdd = false;
                if (meta.max > 10) {
                  if (val0Str.contains(':')) {
                    val0Str = val0Str.substring(0, 4);
                    if (val0Str.length == 4) {
                      val0Str = '0$val0Str';
                    }
                  }

                  isOdd = value % 2 == 0;
                }

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 2,
                  child: Text(
                    val0Str,
                    style: TextStyle(
                      fontSize: isOdd ? 7 : 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: isOdd ? AppTheme.clText07 : AppTheme.clYellow,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: AppTheme.clYellow,
            barWidth: 1,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: AppTheme.clYellow,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.clYellow005,
            ),
            dashArray: [4, 4],
            spots: dataVal,
          ),
        ],
        minX: 0,
        minY: 0,
        maxX: graphDataVal.length + 0.1,
        maxY: maxYc.last + (maxYc.last * 0.1),
      ),
    );
  }
}
