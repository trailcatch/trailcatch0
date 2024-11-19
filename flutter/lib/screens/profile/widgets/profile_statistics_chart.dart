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
import 'package:trailcatch/models/statistic_model.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';

class ProfileStatisticsChart extends StatefulWidget {
  const ProfileStatisticsChart({
    super.key,
    required this.user,
    required this.years,
    required this.page,
    required this.onPageChanged,
  });

  final UserModel user;
  final List<int> years;
  final int page;
  final Function(int page) onPageChanged;

  @override
  State<ProfileStatisticsChart> createState() => _ProfileStatisticsChartState();
}

class _ProfileStatisticsChartState extends State<ProfileStatisticsChart> {
  late PageController _statCtrl;

  late Map<int, Map<int, List<(double, double)>>> _data;
  late Map<int, double> _mmaxDistance;
  late Map<int, double> _ddlCount;

  @override
  void initState() {
    _statCtrl = PageController(
      initialPage: widget.page,
      viewportFraction: 0.98,
    );

    _data = {};
    _mmaxDistance = {};
    _ddlCount = {};

    for (var year in widget.user.statsGit.keys) {
      _mmaxDistance[year] = 0;
      _ddlCount[year] = 0;

      for (var statMonth in widget.user.statsGit[year]!) {
        _genData(statMonth);
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    _statCtrl.dispose();

    super.dispose();
  }

  void _genData(StatisticMonthModel statMonth) {
    final DateTime tdateAt = statMonth.dateAt;
    final int year = tdateAt.year;

    _data.putIfAbsent(year, () => {});
    _data[year]!.putIfAbsent(tdateAt.month, () => []);

    final walk = widget.user.statsTypes[(tdateAt, TrailType.walk, false)];
    final run = widget.user.statsTypes[(tdateAt, TrailType.run, false)];
    final bike = widget.user.statsTypes[(tdateAt, TrailType.bike, false)];

    final walkDogs = widget.user.statsTypes[(tdateAt, TrailType.walk, true)];
    final runDogs = widget.user.statsTypes[(tdateAt, TrailType.run, true)];
    final bikeDogs = widget.user.statsTypes[(tdateAt, TrailType.bike, true)];

    var walkP = (walk?.distance ?? 0) + 0.0;
    var runP = (run?.distance ?? 0) + 0.0;
    var bikeP = (bike?.distance ?? 0) + 0.0;

    var walkD = (walkDogs?.distance ?? 0) + 0.0;
    var runD = (runDogs?.distance ?? 0) + 0.0;
    var bikeD = (bikeDogs?.distance ?? 0) + 0.0;

    if ((walkP + walkD) > _mmaxDistance[year]!) {
      _mmaxDistance[year] = walkP + walkD;
    }

    if ((runP + runD) > _mmaxDistance[year]!) {
      _mmaxDistance[year] = runP + runD;
    }

    if ((bikeP + bikeD) > _mmaxDistance[year]!) {
      _mmaxDistance[year] = bikeP + bikeD;
    }

    _ddlCount[year] = _mmaxDistance[year]! / 100;

    _data[year]![tdateAt.month]!.addAll([
      (walkP, walkD),
      (runP, runD),
      (bikeP, bikeD),
    ]);

    if (_mmaxDistance[year]! == 0) _mmaxDistance[year] = 1;
  }

  int inx = -1;
  Widget _bottomTitles(double value, TitleMeta meta) {
    inx += 1;
    if (inx > 3) inx = 0;

    if (inx != 0) {
      return Container();
    }

    final monthStr = DateTime(1900, value.toInt() + 1, 1).toMonth(isM3: true);

    return Container(
      padding: const EdgeInsets.only(left: 12),
      child: SideTitleWidget(
        axisSide: meta.axisSide,
        space: 4,
        child: Text(
          monthStr.toTitle(),
          style: TextStyle(
            fontSize: appVM.lang == 'ru' ? 10 : 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const walkC = Color.fromARGB(255, 59, 138, 61);
    const walkDC = Color.fromARGB(255, 44, 111, 45);

    const runC = Colors.yellow;
    const runDC = Color.fromARGB(255, 216, 200, 53);

    const bikeC = Color.fromARGB(255, 235, 82, 71);
    const bikeDC = Color.fromARGB(255, 222, 62, 51);

    return Stack(
      children: [
        Container(
          color: AppTheme.clBackground,
          width: context.width,
          height: widget.user.withDogs ? 320 : 310,
          padding: EdgeInsets.only(
            bottom: 5,
            top: widget.user.withDogs ? 45 : 25,
          ),
          child: PageView(
            controller: _statCtrl,
            scrollDirection: Axis.horizontal,
            onPageChanged: widget.onPageChanged,
            children: [
              for (var year in _data.keys)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Max distance: ${fnDistance(_mmaxDistance[year]!.toInt())} ${fnDistUnit()}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.clText05,
                        ),
                      ),
                      SizedBox(
                        height: 245,
                        width: context.width,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceBetween,
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(),
                              rightTitles: const AxisTitles(),
                              topTitles: const AxisTitles(),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: _bottomTitles,
                                  reservedSize: 20,
                                ),
                              ),
                            ),
                            barTouchData: BarTouchData(enabled: false),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                            barGroups: [
                              for (var it in _data[year]!.entries) ...[
                                BarChartGroupData(
                                  x: it.key - 1,
                                  groupVertically: true,
                                  barRods: [
                                    BarChartRodData(
                                      fromY: 0,
                                      toY: (it.value[0].$1 != 0)
                                          ? it.value[0].$1 - _ddlCount[year]!
                                          : 0,
                                      width: 6,
                                      color: walkC,
                                      backDrawRodData:
                                          BackgroundBarChartRodData(
                                        color: AppTheme.clText002,
                                        fromY: 0,
                                        toY: _mmaxDistance[year],
                                        show: true,
                                      ),
                                    ),
                                    BarChartRodData(
                                      fromY: it.value[0].$1,
                                      toY: it.value[0].$1 + it.value[0].$2,
                                      width: 5,
                                      color: walkDC,
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: it.key,
                                  groupVertically: true,
                                  barRods: [
                                    BarChartRodData(
                                      fromY: 0,
                                      toY: it.value[1].$1 != 0
                                          ? it.value[1].$1 - _ddlCount[year]!
                                          : 0,
                                      width: 6,
                                      color: runC,
                                      backDrawRodData:
                                          BackgroundBarChartRodData(
                                        color: AppTheme.clText002,
                                        fromY: 0,
                                        toY: _mmaxDistance[year],
                                        show: true,
                                      ),
                                    ),
                                    BarChartRodData(
                                      fromY: it.value[1].$1,
                                      toY: it.value[1].$1 + it.value[1].$2,
                                      width: 5,
                                      color: runDC,
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: it.key + 1,
                                  groupVertically: true,
                                  barRods: [
                                    BarChartRodData(
                                      fromY: 0,
                                      toY: it.value[2].$1 != 0
                                          ? it.value[2].$1 - _ddlCount[year]!
                                          : 0,
                                      width: 6,
                                      color: bikeC,
                                      backDrawRodData:
                                          BackgroundBarChartRodData(
                                        color: AppTheme.clText002,
                                        fromY: 0,
                                        toY: _mmaxDistance[year],
                                        show: true,
                                      ),
                                    ),
                                    BarChartRodData(
                                      fromY: it.value[2].$1,
                                      toY: it.value[2].$1 + it.value[2].$2,
                                      width: 5,
                                      color: bikeDC,
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: it.key + 2,
                                  groupVertically: true,
                                  barRods: [
                                    BarChartRodData(
                                      fromY: 0,
                                      toY: _mmaxDistance[year]!,
                                      width: 6,
                                      color: AppTheme.clBackground,
                                    ),
                                  ],
                                )
                              ],
                            ],
                            maxY: _mmaxDistance[year]!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: context.width,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.user.withDogs)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 7,
                            width: 7,
                            decoration: const BoxDecoration(
                              color: walkDC,
                              shape: BoxShape.circle,
                            ),
                          ),
                          4.w,
                          const Text(
                            'Walk & Dogs',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 9,
                          width: 9,
                          decoration: const BoxDecoration(
                            color: walkC,
                            shape: BoxShape.circle,
                          ),
                        ),
                        4.w,
                        const Text(
                          'Walk',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.user.withDogs)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 7,
                            width: 7,
                            decoration: const BoxDecoration(
                              color: runDC,
                              shape: BoxShape.circle,
                            ),
                          ),
                          4.w,
                          const Text(
                            'Run & Dogs',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 9,
                          width: 9,
                          decoration: const BoxDecoration(
                            color: runC,
                            shape: BoxShape.circle,
                          ),
                        ),
                        4.w,
                        const Text(
                          'Run',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.user.withDogs)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 7,
                            width: 7,
                            decoration: const BoxDecoration(
                              color: bikeDC,
                              shape: BoxShape.circle,
                            ),
                          ),
                          4.w,
                          const Text(
                            'Bike & Dogs',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 9,
                          width: 9,
                          decoration: const BoxDecoration(
                            color: bikeC,
                            shape: BoxShape.circle,
                          ),
                        ),
                        4.w,
                        const Text(
                          'Bike',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
