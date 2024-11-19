// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:url_launcher/url_launcher.dart';

class TrailCardGraph extends StatelessWidget {
  const TrailCardGraph({
    super.key,
    required this.trailGraphData,
    required this.active,
    required this.onChangeMsrunit,
    required this.onRebuild,
  });

  final TrailGraphData trailGraphData;
  final bool active;
  final Function(int value) onChangeMsrunit;
  final VoidCallback onRebuild;

  @override
  Widget build(BuildContext context) {
    late String msur1;
    late String msur2;

    late Color msur1c;
    late Color msur2c;

    late FontWeight msur1fw;
    late FontWeight msur2fw;

    if (trailGraphData.msrunit0 == UserMeasurementUnit.km) {
      msur1 = 'km';
      msur2 = 'miles';

      msur1c = trailGraphData.msrunit0 == trailGraphData.msrunit
          ? AppTheme.clYellow
          : AppTheme.clText05;
      msur2c = trailGraphData.msrunit0 != trailGraphData.msrunit
          ? AppTheme.clYellow
          : AppTheme.clText05;

      msur1fw = trailGraphData.msrunit0 == trailGraphData.msrunit
          ? FontWeight.bold
          : FontWeight.normal;
      msur2fw = trailGraphData.msrunit0 != trailGraphData.msrunit
          ? FontWeight.bold
          : FontWeight.normal;
    } else {
      msur1 = 'miles';
      msur2 = 'km';

      msur1c = trailGraphData.msrunit0 != trailGraphData.msrunit
          ? AppTheme.clYellow
          : AppTheme.clText05;
      msur2c = trailGraphData.msrunit0 == trailGraphData.msrunit
          ? AppTheme.clYellow
          : AppTheme.clText05;

      msur1fw = trailGraphData.msrunit0 != trailGraphData.msrunit
          ? FontWeight.bold
          : FontWeight.normal;
      msur2fw = trailGraphData.msrunit0 == trailGraphData.msrunit
          ? FontWeight.bold
          : FontWeight.normal;
    }

    bool showGraph = trailGraphData.graphDataVal.isNotEmpty &&
        trailGraphData.graphDataDist.isNotEmpty &&
        trailGraphData.graphDataTime.isNotEmpty;

    bool showMsunit = trailGraphData.msrunit0 != appVM.settings.msrunit;
    if (!showGraph) showMsunit = false;

    String infoUrl = '';
    Widget wInfo = AppGestureButton(
      onTry: () async {
        AppRoute.showPopup(
          [
            AppPopupAction(
              'Read Info',
              () async {
                launchUrl(Uri.parse(infoUrl));
              },
            ),
          ],
        );
      },
      child: const Text(
        'Info',
        style: TextStyle(
          fontSize: 13,
          letterSpacing: 0.6,
          fontWeight: FontWeight.bold,
          color: AppTheme.clBlue08,
        ),
      ),
    );

    if (trailGraphData.key == TrailGraphData.kTrainingEff) {
      infoUrl = 'https://support.garmin.com/en-US/?faq=Vi2undejXR5Mmq662o4lO9';
    } else if (trailGraphData.key == TrailGraphData.kPeakTrainingEff) {
      infoUrl =
          'https://www.suunto.com/en-gb/Support/Product-support/suunto_7/suunto_7/glossary/';
    }
    // else if (trailGraphData.key == TrailGraphData.kCalories) {
    //   infoUrl = 'https://en.wikipedia.org/wiki/Calorie';
    // }

    // showMsunit = true;

    String keyStr = TrailGraphData.formatKeyToStr(trailGraphData.key);
    if (trailGraphData.key == TrailGraphData.kCadences &&
        trailGraphData.type == TrailType.bike) {
      keyStr = 'Bike $keyStr';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                keyStr,
                style: const TextStyle(
                  fontSize: 16,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              if (showMsunit)
                AppGestureButton(
                  onTap: () {
                    onChangeMsrunit(
                      trailGraphData.msrunit == UserMeasurementUnit.km
                          ? UserMeasurementUnit.miles
                          : UserMeasurementUnit.km,
                    );
                  },
                  child: Container(
                    color: AppTheme.clBackground,
                    height: 20,
                    padding: const EdgeInsets.only(left: 15),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: AppTheme.ffUbuntuRegular,
                          fontSize: 13,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: msur1,
                            style: TextStyle(
                              color: msur1c,
                              fontWeight: msur1fw,
                            ),
                          ),
                          const TextSpan(
                            text: '   |   ',
                            style: TextStyle(
                              color: AppTheme.clText08,
                            ),
                          ),
                          TextSpan(
                            text: msur2,
                            style: TextStyle(
                              color: msur2c,
                              fontWeight: msur2fw,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (infoUrl.isNotEmpty)
                wInfo
              else
                10.w,
            ],
          ),
        ),
        5.hrr(height: 0.5, color: AppTheme.clText02, padLR: AppTheme.appLR),
        5.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${trailGraphData.labelLeft}:',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.clText08,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  if (trailGraphData.labelCenter?.isNotEmpty ?? false)
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${trailGraphData.labelCenter}:',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.clText08,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  if (trailGraphData.valueRight.isNotEmpty)
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${trailGraphData.labelRight}:',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.clText08,
                        ),
                        textAlign:
                            trailGraphData.valueCenter?.isNotEmpty ?? false
                                ? TextAlign.center
                                : TextAlign.start,
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          trailGraphData.valueLeft,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        1.w,
                        Container(
                          padding: const EdgeInsets.only(
                            bottom: 12,
                            left: 1,
                          ),
                          child: Text(
                            trailGraphData.suff,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppTheme.clText08,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailGraphData.valueCenter?.isNotEmpty ?? false)
                    Expanded(
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            trailGraphData.valueCenter!,
                            style: TextStyle(
                              fontSize: trailGraphData.valueCenter!.length > 10
                                  ? 17
                                  : 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          1.w,
                          Container(
                            padding: const EdgeInsets.only(
                              bottom: 18,
                              left: 1,
                            ),
                            child: Text(
                              trailGraphData.suff,
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppTheme.clText08,
                              ),
                            ),
                          ),
                          2.w,
                        ],
                      ),
                    ),
                  if (trailGraphData.valueRight.isNotEmpty)
                    Expanded(
                      flex: 2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment:
                            trailGraphData.valueCenter?.isNotEmpty ?? false
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                        children: [
                          Text(
                            trailGraphData.valueRight,
                            style: TextStyle(
                              fontSize: trailGraphData.valueRight.length > 10
                                  ? 19
                                  : 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          1.w,
                          Container(
                            padding: const EdgeInsets.only(
                              bottom: 18,
                              left: 1,
                            ),
                            child: Text(
                              trailGraphData.suff,
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppTheme.clText08,
                              ),
                            ),
                          ),
                          2.w,
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (showGraph) ...[
          10.h,
          AppGestureButton(
            onTap: () {
              // if (trailGraphData.graphDataDist.length >= 10) {
              onRebuild();
              // }
            },
            child: SizedBox(
              width: context.width,
              height: 140,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.appLR * 2,
                ),
                child: TrailCardGraphCanvas(
                  trailGraphData: trailGraphData,
                  active: active,
                ),
              ),
            ),
          ),
        ],
        if (trailGraphData.key == TrailGraphData.kTrainingEff)
          TrailCardGraphLine(
            vals: [
              double.tryParse(trailGraphData.valueLeft) ?? 0.0,
              double.tryParse(trailGraphData.valueRight) ?? 0.0
            ],
          ),
        if (trailGraphData.key == TrailGraphData.kPeakTrainingEff)
          TrailCardGraphLine(
            vals: [
              double.tryParse(trailGraphData.valueLeft) ?? 0.0,
            ],
          ),
      ],
    );
  }
}

class TrailCardGraphCanvas extends StatelessWidget {
  const TrailCardGraphCanvas({
    super.key,
    required this.trailGraphData,
    required this.active,
  });

  final TrailGraphData trailGraphData;
  final bool active;

  @override
  Widget build(BuildContext context) {
    List<FlSpot> dataVal = [
      const FlSpot(0, 0),
    ];

    trailGraphData.graphDataVal.asMap().forEach((inx, griVal) {
      dataVal.add(FlSpot(
        inx + 1.0,
        griVal + 0.0,
      ));
    });

    List<FlSpot> dataDist = [const FlSpot(0, 0)];
    trailGraphData.graphDataDist.asMap().forEach((inx, gritDist) {
      dataDist.add(FlSpot(
        inx + 1.0,
        gritDist + 0.0,
      ));
    });

    List<FlSpot> dataTime = [const FlSpot(0, 0)];
    trailGraphData.graphDataTime.asMap().forEach((inx, gritTime) {
      dataTime.add(FlSpot(
        inx + 1.0,
        gritTime + 0.0,
      ));
    });

    final List<int> maxYc = List<int>.from(trailGraphData.graphDataVal);
    maxYc.sort();

    final List<int> maxXc = List<int>.from(trailGraphData.graphDataDist);
    maxXc.sort();

    return LineChart(
      LineChartData(
        lineTouchData: const LineTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          verticalInterval: 1,
          drawHorizontalLine: false,
          getDrawingVerticalLine: (value) {
            return const FlLine(
              color: AppTheme.clText04,
              strokeWidth: 0.4,
              dashArray: [3, 2],
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
                if (value == meta.max) return const Text('');

                var val = value.toInt();
                double val0 = 0.0;
                for (var it in dataVal) {
                  if (it.x == val) {
                    val0 = it.y;
                    break;
                  }
                }

                String val0Str = val0.toStringAsFixed(0);
                if (trailGraphData.key == TrailGraphData.kSpeeds) {
                  val0Str = fnTimeExt(
                    fnParseSpeedSec(val0.toInt(), trailGraphData.msrunit),
                    zero1th: false,
                  );
                } else if (trailGraphData.key == TrailGraphData.kPaces) {
                  val0Str = fnTimeExt(
                    fnParsePaceSec(val0.toInt(), trailGraphData.msrunit),
                    zero1th: false,
                  );
                }

                bool isOdd = false;

                if ((trailGraphData.key == TrailGraphData.kSpeeds ||
                        trailGraphData.key == TrailGraphData.kPaces) &&
                    meta.max > 10) {
                  if (val0Str.contains(':')) {
                    val0Str = val0Str.substring(0, 4);
                    if (val0Str.length == 4) {
                      val0Str = '0$val0Str';
                    }
                  }

                  isOdd = value % 2 == 0;
                }

                bool isSuff = false;
                if (value == meta.min && val0 == 0) {
                  val0Str = trailGraphData.suff;
                  isSuff = true;
                }

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 6,
                  child: Container(
                    padding: EdgeInsets.only(top: !isOdd ? 0 : 3),
                    child: Text(
                      val0Str,
                      style: TextStyle(
                        fontSize: isSuff ? 9 : (!isOdd ? 11 : 10),
                        fontWeight:
                            isSuff ? FontWeight.normal : FontWeight.bold,
                        letterSpacing: 0.6,
                        color: active
                            ? (!isOdd
                                ? trailGraphData.graphColorMain
                                : AppTheme.clText08)
                            : AppTheme.clText05,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value == meta.max) {
                  return const Text('');
                }

                double val2 = 0.0;
                double val3 = 0.0;

                var inx2 = dataDist.indexWhere((dt2) => dt2.x == value);
                if (inx2 != -1) {
                  var it2 = dataDist.elementAtOrNull(inx2);
                  if (it2 == null) return const Text('');
                  val2 = it2.y;

                  var it3 = dataTime.elementAtOrNull(inx2);
                  if (it3 == null) return const Text('');
                  val3 = it3.y;
                }

                String val2Str = (val2 / 100).toStringAsFixed(2);
                if (val2Str.endsWith('.00')) {
                  val2Str = val2Str.replaceAll('.00', '');
                }

                String val3Str = fnTimeExt(val3.toInt());
                if (val3Str.contains(':')) {
                  val3Str = val3Str.substring(0, 4);
                  if (val3Str.length == 4) {
                    val3Str = '0$val3Str';
                  }
                }

                bool isOdd = false;
                if (meta.max > 10) {
                  isOdd = value % 2 == 0;
                }

                if (value == meta.min && val3 == 0) {
                  val3Str = '';
                }

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 6,
                  child: Column(
                    children: [
                      Text(
                        val2Str,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: !isOdd ? 1 : 4),
                        child: Text(
                          val3Str,
                          style: TextStyle(
                            fontSize: !isOdd ? 10 : 9,
                            color: !isOdd ? AppTheme.clText : AppTheme.clText07,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
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
            color: active ? trailGraphData.graphColorMain : AppTheme.clText05,
            barWidth: 1,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: active
                      ? trailGraphData.graphColorMain
                      : AppTheme.clText05,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: trailGraphData.graphColorBack,
            ),
            dashArray: [4, 4],
            spots: dataVal,
          ),
        ],
        minX: 0,
        minY: 0,
        maxX: trailGraphData.graphDataDist.length + 0.1,
        maxY: maxYc.last + (maxYc.last * 0.1),
      ),
    );
  }
}

class TrailCardGraphLine extends StatelessWidget {
  const TrailCardGraphLine({
    super.key,
    required this.vals,
  });

  final List<double> vals;

  Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    String txt = '';
    if (value % 20 == 0) {
      txt = (value / 20).toStringAsFixed(0);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        txt,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.clText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEmp = vals.first == 0 && vals.last == 0;

    List<Color> colors = [
      const Color.fromARGB(255, 92, 92, 95),
      const Color.fromARGB(255, 63, 164, 246),
      const Color.fromARGB(255, 63, 164, 246),
      const Color.fromARGB(255, 43, 163, 47),
      const Color.fromARGB(255, 254, 160, 20),
      const Color.fromARGB(255, 255, 48, 33),
    ];

    if (isEmp) {
      colors = [
        colors[0],
        colors[0],
        colors[0],
        colors[0],
        colors[0],
        colors[0],
      ];
    }

    double valMax = 5.2;
    List<int> values = [];

    for (var val in vals) {
      if (val < 0) val = 0;
      if (val > valMax) valMax = val;
      values.add((val * 10 * 2).toInt());
    }

    final lineBarsData = [
      LineChartBarData(
        showingIndicators: values,
        spots: [
          for (var it
              in List.generate((valMax * 10 * 2).toInt() + 1, (int inx) => inx))
            if (isEmp)
              FlSpot(it.toDouble(), 0)
            else
              FlSpot(it.toDouble(), (it % 2 == 0 ? it : it + 2).toDouble()),
        ],
        isCurved: false,
        barWidth: 3,
        dotData: const FlDotData(show: false),
        dashArray: [6, 4],
        gradient: LinearGradient(
          colors: colors,
          stops: const [0.15, 0.25, 0.28, 0.6, 0.8, 0.95],
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return AspectRatio(
      aspectRatio: 2.7,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 25.0,
          vertical: 15,
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          return LineChart(
            LineChartData(
              showingTooltipIndicators: values.map((index) {
                return ShowingTooltipIndicators([
                  LineBarSpot(
                    tooltipsOnBar,
                    lineBarsData.indexOf(tooltipsOnBar),
                    tooltipsOnBar.spots[index],
                  ),
                ]);
              }).toList(),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: false,
                getTouchedSpotIndicator: (
                  LineChartBarData barData,
                  List<int> spotIndexes,
                ) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      const FlLine(color: Colors.transparent),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          Color color = Colors.transparent;

                          percent = ((percent / 10).floor() / 10).toDouble();

                          if (percent > 0.8) {
                            color = colors[5];
                          } else if (percent > 0.6 && percent <= 0.8) {
                            color = colors[4];
                          } else if (percent > 0.3 && percent <= 0.6) {
                            color = colors[3];
                          } else if (percent > 0.25 && percent <= 0.3) {
                            color = colors[2];
                          } else if (percent > 0.15 && percent <= 0.25) {
                            color = colors[1];
                          } else if (percent <= 0.15) {
                            color = colors[0];
                          }

                          return FlDotCirclePainter(
                            radius: 7,
                            strokeWidth: 2.5,
                            strokeColor: AppTheme.clBlack,
                            color: color,
                          );
                        },
                      ),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => Colors.transparent,
                  getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                    return lineBarsSpot.map((lineBarSpot) {
                      return LineTooltipItem(
                        (lineBarSpot.y / 20).toStringAsFixed(1),
                        const TextStyle(
                          fontSize: 14,
                          color: AppTheme.clText,
                          fontWeight: FontWeight.bold,
                          height: 0.1,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: lineBarsData,
              minY: 0,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return bottomTitleWidgets(
                        value,
                        meta,
                        constraints.maxWidth,
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                verticalInterval: 10,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) {
                  return const FlLine(
                    color: AppTheme.clText02,
                    strokeWidth: 0.5,
                    dashArray: [3, 2],
                  );
                },
                getDrawingVerticalLine: (value) {
                  return const FlLine(
                    color: AppTheme.clText02,
                    strokeWidth: 0.5,
                    dashArray: [3, 2],
                  );
                },
              ),
              borderData: FlBorderData(show: false),
            ),
          );
        }),
      ),
    );
  }
}
