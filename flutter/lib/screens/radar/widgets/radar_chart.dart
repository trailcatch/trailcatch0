// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trailcatch/constants.dart';
import 'package:trailcatch/route.dart';

import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:url_launcher/url_launcher.dart';

class RadarChartExt extends StatefulWidget {
  const RadarChartExt({
    super.key,
    required this.dist8th,
    required this.onShake,
    this.onDetails,
  });

  final List<List<dynamic>> dist8th;
  final Function(double shakeDist) onShake;
  final VoidCallback? onDetails;

  @override
  State<RadarChartExt> createState() => _RadarChartExtState();
}

class _RadarChartExtState extends State<RadarChartExt> {
  late bool _animEnd;
  late double _shakeDist;

  late List<List<dynamic>> _citie0;
  late List<List<dynamic>> _cities;

  @override
  void initState() {
    _animEnd = false;
    _shakeDist = cstDefRadarMaxDistance;

    _citie0 = widget.dist8th;

    if (_citie0.first.last != 0) {
      _cities = widget.dist8th.map((cti) => [cti.first, 0.1]).toList();

      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          setState(() {
            _animEnd = true;
            _cities = _citie0;
          });
        }
      });
    } else {
      _cities = widget.dist8th;
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant RadarChartExt oldWidget) {
    _citie0 = widget.dist8th;
    _cities = widget.dist8th;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpt = _cities.first.last == 0;

    String parseCityExtStr(int inx) {
      final String cityStr = _citie0[inx].first;
      final double distVal = _citie0[inx].last;

      String text = '$cityStr ~ ${distVal.toStringAsFixed(0)}';
      if (isEmpt || distVal == 0) {
        text = '';
      }

      return '$text, ${cstRadarDers[inx]}';
    }

    return AppGestureButton(
      onTap: () {
        if (isEmpt) return;

        late double shakeDist0;
        if (cstRadarMaxDistance.last == _shakeDist) {
          shakeDist0 = cstRadarMaxDistance.first;
        } else {
          shakeDist0 =
              cstRadarMaxDistance[cstRadarMaxDistance.indexOf(_shakeDist) + 1];
        }

        AppRoute.showPopup(
          [
            for (var inx in List.generate(8, (i) => i))
              if (_citie0[inx].first != '')
                AppPopupAction(
                  parseCityExtStr(inx),
                  () async {
                    launchUrl(Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=${_citie0[inx].first}',
                    ));
                  },
                ),
          ],
          bottoms: [
            if (widget.onDetails != null)
              AppPopupAction(
                'Show Trail Details',
                () async {
                  widget.onDetails!();
                },
              ),
            AppPopupAction(
              'Catch Next Map ~ ${shakeDist0.toStringAsFixed(0)} ${fnDistUnit()}',
              color: AppTheme.clYellow,
              () async {
                _shakeDist = shakeDist0;
                widget.onShake(_shakeDist);
              },
            ),
          ],
        );
      },
      onDoubleTap: () {
        if (isEmpt) return;

        widget.onShake(_shakeDist);
      },
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: _animEnd ? AppTheme.clText002 : AppTheme.clText01,
              borderColor: AppTheme.clText04,
              borderWidth: 2,
              entryRadius: isEmpt ? 0 : 4,
              dataEntries: [
                _citie0[0].last,
                _citie0[1].last,
                _citie0[2].last,
                _citie0[3].last,
                _citie0[4].last,
                _citie0[5].last,
                _citie0[6].last,
                _citie0[7].last,
              ].map((e) => RadarEntry(value: e)).toList(),
            ),
            RadarDataSet(
              fillColor: _animEnd ? AppTheme.clText02 : AppTheme.clText005,
              borderColor: _animEnd ? AppTheme.clYellow : AppTheme.clText01,
              borderWidth: 2,
              entryRadius: isEmpt ? 0 : 4,
              dataEntries: [
                _cities[0].last,
                _cities[1].last,
                _cities[2].last,
                _cities[3].last,
                _cities[4].last,
                _cities[5].last,
                _cities[6].last,
                _cities[7].last,
              ].map((e) => RadarEntry(value: e)).toList(),
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(
            show: false,
            border: Border.all(
              width: 0.5,
              color: AppTheme.clText03,
            ),
          ),
          radarBorderData: BorderSide(
            color: isEmpt ? AppTheme.clText01 : AppTheme.clText04,
            width: 1,
          ),
          gridBorderData: BorderSide(
            color: isEmpt ? AppTheme.clText01 : AppTheme.clText04,
            width: 1,
          ),
          titlePositionPercentageOffset: 0.05,
          titleTextStyle: const TextStyle(
            color: AppTheme.clText08,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          ticksTextStyle: TextStyle(
            color: isEmpt ? AppTheme.clText03 : AppTheme.clText,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          tickBorderData: const BorderSide(
            color: AppTheme.clText005,
          ),
          getTitle: (index, _) {
            final String text = _citie0[index].first;

            switch (index) {
              case 0:
                return RadarChartTitle(text: text, angle: 0);
              case 1:
                return RadarChartTitle(text: text, angle: 45);
              case 2:
                return RadarChartTitle(text: text, angle: 90);
              case 3:
                return RadarChartTitle(text: text, angle: -45);
              case 4:
                return RadarChartTitle(text: text, angle: 0);
              case 5:
                return RadarChartTitle(text: text, angle: 45);
              case 6:
                return RadarChartTitle(text: text, angle: -90);
              case 7:
                return RadarChartTitle(text: text, angle: -45);
              default:
                return const RadarChartTitle(text: '');
            }
          },
          radarShape: RadarShape.polygon,
          tickCount: 4,
        ),
        swapAnimationDuration: const Duration(milliseconds: 1300),
        swapAnimationCurve: Curves.linearToEaseOut,
      ),
    );
  }
}
