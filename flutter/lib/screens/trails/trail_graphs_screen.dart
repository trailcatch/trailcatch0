// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';
import 'package:trailcatch/widgets/text.dart';

class TrailCardDetailsGraphsScreen extends StatefulWidget {
  const TrailCardDetailsGraphsScreen({
    super.key,
    required this.trailExt,
  });

  final TrailExtModel trailExt;

  static final li = [
    ['Pace', '\\km'],
    ['Heart Rate', 'bpm'],
    ['Cadence', 'spm'],
    ['Elevation', 'm'],
    ['Power', 'watt'],
  ];

  static final lic = [
    Colors.yellow,
    AppTheme.clDeepOrange,
    Colors.blue,
    Colors.pink[50],
    Colors.green,
  ];

  @override
  State<TrailCardDetailsGraphsScreen> createState() =>
      _TrailCardDetailsGraphsScreenState();
}

class _TrailCardDetailsGraphsScreenState
    extends State<TrailCardDetailsGraphsScreen> {
  String gender = 'Mail';

  int _value = 0;

  final _ctrl = ScrollController();
  GlobalKey key = GlobalKey();

  @override
  void initState() {
    _ctrl.addListener(() {
      RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
      Offset position = box.localToGlobal(Offset.zero);
      double x = position.dx.abs() + 30;

      var dttt = x ~/ 73;

      if (_value != dttt) {
        setState(() {
          _value = dttt.toInt();
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _ctrl333 = PageController(
      viewportFraction: 0.4,
      initialPage: 1,
    );

    return AppSimpleScaffold(
      title: 'Trail Graph',
      actions: [],
      child: Container(
        height: context.height,
        width: context.width,
        child: Column(
          children: [
            // Container(
            //   width: context.width,
            //   height: 3,
            //   color: Colors.black,
            // ),
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    left: 58,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 77,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        border: const Border(
                          left: BorderSide(width: 2, color: Colors.black),
                          right: BorderSide(width: 2, color: Colors.black),
                          top: BorderSide(width: 2, color: AppTheme.clYellow),
                          bottom:
                              BorderSide(width: 2, color: AppTheme.clYellow),
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    controller: _ctrl,
                    child: SizedBox(
                      width: 20 * 90,
                      height: context.height,
                      child: Row(
                        children: [
                          SizedBox(key: key, width: 5, height: 10),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                children: [
                                  for (var it
                                      in List.generate(5, (i) => i)) ...[
                                    Column(
                                      children: [
                                        15.h,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            for (var it2 in [0, 1])
                                              Container(
                                                width: context.width - 20,
                                                padding: EdgeInsets.only(
                                                  left: it2 == 0 ? 0 : 0,
                                                  right: it2 == 1 ? 70 : 0,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    AppText.tsRegular(
                                                            TrailCardDetailsGraphsScreen
                                                                .li[it].first)
                                                        .tsFontSize(13)
                                                        .tsFontWeight(
                                                            FontWeight.bold)
                                                        .tsColor(
                                                            TrailCardDetailsGraphsScreen
                                                                .lic[it]!)
                                                        .tsOpacity(0.8),
                                                    1.w,
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 4,
                                                        left: 1,
                                                      ),
                                                      child: AppText.tsMedium(
                                                              TrailCardDetailsGraphsScreen
                                                                  .li[it].last)
                                                          .tsColor(
                                                              TrailCardDetailsGraphsScreen
                                                                  .lic[it]!)
                                                          .tsFontSize(8)
                                                          .tsOpacity(0.5),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                // width: context.width * (1 + (0.25 * 11)),
                                                // width: context.width,
                                                height: 165,
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                    left: 8,
                                                    right: 0,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.only(
                                                    right: 10,
                                                    left: 10,
                                                    top: 8,
                                                    bottom: 5,
                                                  ),
                                                  // decoration: BoxDecoration(
                                                  //   border: Border(
                                                  //     bottom: BorderSide(
                                                  //         width: 5,
                                                  //         color: Colors.black),
                                                  //   ),
                                                  // ),
                                                  child: LineChartSample2cccc(
                                                    selected: _value,
                                                    tp: it,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (it == 4) 25.h,
                                  ],
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: context.width * 0.72,
                            color: Colors.red,
                            height: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black,
              width: context.width,
              height: 2,
            ),
            10.h,
            Container(
              padding: const EdgeInsets.only(right: 15, left: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    child: Container(
                      alignment: Alignment.center,
                      child: AppText.tsMedium('14').tsFontSize(20),
                    ),
                  ),
                  10.w,
                  Container(
                    alignment: Alignment.center,
                    child: AppText.tsMedium('/').tsFontSize(20),
                  ),
                  10.w,
                  SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppText.tsMedium('4').tsFontSize(20),
                        AppText.tsMedium(':').tsFontSize(20),
                        AppText.tsMedium('41').tsFontSize(20),
                        Container(
                          padding: const EdgeInsets.only(
                            bottom: 2,
                            left: 1,
                          ),
                          child: Row(
                            children: [
                              AppText.tsMedium(':').tsFontSize(14),
                              AppText.tsMedium('32').tsFontSize(14),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 80,
              width: context.width,
              // color: AppTheme.clBackground,
              // color: Colors.red,
              child: Container(
                padding: const EdgeInsets.only(top: 10),
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment(-2, 0),
                      child: PageView(
                        controller: _ctrl333,
                        onPageChanged: (value) {
                          if (value >= 1) {
                            setState(() {
                              _value = value;
                            });
                          }

                          if (value == 0) {
                            _ctrl333.animateToPage(
                              1,
                              curve: Curves.linear,
                              duration: const Duration(milliseconds: 500),
                            );
                          }
                          //else if (value == 1) {
                          //   _ctrl333.animateToPage(
                          //     2,
                          //     curve: Curves.linear,
                          //     duration: const Duration(milliseconds: 250),
                          //   );
                          // }
                          // else if (value == 2) {
                          //   _ctrl333.animateToPage(
                          //     3,
                          //     curve: Curves.linear,
                          //     duration: const Duration(milliseconds: 250),
                          //   );
                          // }
                        },
                        children: [
                          Container(),
                          for (var it in List.generate(10, (i) => i))
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left:
                                      BorderSide(width: 2, color: Colors.black),
                                  right:
                                      BorderSide(width: 2, color: Colors.black),
                                  top:
                                      BorderSide(width: 2, color: Colors.black),
                                  bottom: BorderSide(
                                    width: 2,
                                    color: _value == (it + 1)
                                        ? AppTheme.clYellow
                                        : AppTheme.clBlack,
                                  ),
                                ),
                                // border: Border.all(
                                //   width: _value == (it + 1) ? 1 : 1,
                                //   color: _value == (it + 1)
                                //       ? AppTheme.clYellow
                                //       // ? AppTheme.clBlack
                                //       : AppTheme.clBlack,
                                // ),
                              ),
                              margin: const EdgeInsets.only(right: 30),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      AppText.tsMedium('${it + 1}')
                                          .tsFontSize(20),
                                      3.w,
                                      Container(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: AppText.tsMedium('km')
                                            .tsFontSize(10)
                                            .tsColor(AppTheme.clText2),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      AppText.tsMedium('5').tsFontSize(20),
                                      AppText.tsMedium(':').tsFontSize(20),
                                      AppText.tsMedium('26').tsFontSize(20),
                                      Container(
                                        padding: const EdgeInsets.only(
                                          bottom: 3,
                                          left: 2,
                                        ),
                                        child: Row(
                                          children: [
                                            AppText.tsMedium(':')
                                                .tsFontSize(12)
                                                .tsColor(AppTheme.clText2),
                                            AppText.tsMedium('34')
                                                .tsColor(AppTheme.clText2)
                                                .tsFontSize(12),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          // Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            (context.notch + 10).h,
          ],
        ),
      ),
    );
  }
}
