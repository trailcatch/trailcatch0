// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/screens/profile/widgets/profile_row_stat.dart';
import 'package:trailcatch/screens/profile/widgets/profile_statistics_chart.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class ProfileStatisticsScreen extends StatefulWidget {
  const ProfileStatisticsScreen({
    super.key,
    required this.user,
    this.year,
  });

  final UserModel user;
  final int? year;

  @override
  State<ProfileStatisticsScreen> createState() =>
      _ProfileStatisticsScreenState();
}

class _ProfileStatisticsScreenState extends State<ProfileStatisticsScreen> {
  late UserModel _user;
  late int _year;

  late int _page;

  @override
  void initState() {
    _user = widget.user;
    _year = widget.year ?? DateTime.now().year;

    _page = 0;

    for (var statYear in _user.statsGit.keys) {
      if (statYear == _year) {
        break;
      } else {
        _page += 1;
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<int> years = List<int>.from(_user.statsGit.keys);

    final inxYear = _user.statsGit.keys.toList()[_page];
    final isYearP = _user.statsGit.keys.contains(inxYear - 1);
    final isYearN = _user.statsGit.keys.contains(inxYear + 1);

    final statYear = _user.statsGit[inxYear]!;

    final sCount = statYear.fold(0, (acc, it) => acc + it.count);
    final sDistance = statYear.fold(0, (acc, it) => acc + it.distance);
    final sElevation = statYear.fold(0, (acc, it) => acc + it.elevation);
    final sTime = statYear.fold(0, (acc, it) => acc + it.time);

    final sstyP = statYear.map((it) => it.avgPace).toList();
    final sstyS = statYear.map((it) => it.avgSpeed).toList();

    final sAvgPace = sstyP.isNotEmpty ? sstyP.average.toInt() : 0;
    final sAvgSpeed = sstyS.isNotEmpty ? sstyS.average.toInt() : 0;

    return AppSimpleScaffold(
      title: 'Statistics',
      child: SizedBox(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              5.h,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${inxYear - 1}',
                      style: TextStyle(
                        fontSize: 15,
                        color: isYearP ? AppTheme.clText : AppTheme.clText02,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$inxYear',
                      style: const TextStyle(
                        fontSize: 22,
                        color: AppTheme.clYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${inxYear + 1}',
                      style: TextStyle(
                        fontSize: 15,
                        color: isYearN ? AppTheme.clText : AppTheme.clText02,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              5.hrr(
                height: 0.5,
                color: AppTheme.clText02,
                padLR: AppTheme.appLR,
              ),
              10.h,
              ProfileRowStat(
                count: sCount,
                distance: sDistance,
                elevation: sElevation,
                time: sTime,
                avgPace: sAvgPace,
                avgSpeed: sAvgSpeed,
                hideAvg: true,
              ),
              25.h,
              ProfileStatisticsChart(
                user: _user,
                years: years,
                page: _page,
                onPageChanged: (int page) {
                  setState(() {
                    _page = page;
                  });
                },
              ),
              Container(
                height: 2,
                width: 120,
                decoration: const BoxDecoration(
                  color: AppTheme.clYellow,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
              25.h,
              0.dl,
              for (var statMonth in statYear) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.appLR,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    statMonth.dateAt.toDate(isY2: true, isD: false),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.clYellow,
                    ),
                  ),
                ),
                5.hrr(
                  height: 0.5,
                  color: AppTheme.clText01,
                  padLR: AppTheme.appLR,
                ),
                10.h,
                for (var typeStr in TrailType.allExtStr) ...[
                  LayoutBuilder(builder: (context, _) {
                    Widget header = Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.appLR,
                        vertical: 5,
                      ),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        border: Border(
                          top: BorderSide(
                            width: 1,
                            color: AppTheme.clBlack,
                          ),
                          bottom: BorderSide(
                            width: 1,
                            color: AppTheme.clBlack,
                          ),
                          right: BorderSide(
                            width: 1,
                            color: AppTheme.clBlack,
                          ),
                        ),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            typeStr,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.clText07,
                            ),
                          ),
                        ],
                      ),
                    );

                    final tdateAt = DateTime(
                      statMonth.dateAt.year,
                      statMonth.dateAt.month,
                      1,
                    );

                    if (typeStr == 'All Trails') {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Opacity(
                                opacity: 0.3,
                                child: header,
                              ),
                            ],
                          ),
                          ProfileRowStat(
                            count: statMonth.count,
                            distance: statMonth.distance,
                            elevation: statMonth.elevation,
                            time: statMonth.time,
                            avgPace: statMonth.avgPace,
                            avgSpeed: statMonth.avgSpeed,
                          ),
                          25.h,
                        ],
                      );
                    } else {
                      late int type;
                      late bool withDogs;

                      if (typeStr == 'Walk') {
                        type = TrailType.walk;
                        withDogs = false;
                      } else if (typeStr == 'Walk & Dogs') {
                        type = TrailType.walk;
                        withDogs = true;
                      } else if (typeStr == 'Run') {
                        type = TrailType.run;
                        withDogs = false;
                      } else if (typeStr == 'Run & Dogs') {
                        type = TrailType.run;
                        withDogs = true;
                      } else if (typeStr == 'Bike') {
                        type = TrailType.bike;
                        withDogs = false;
                      } else if (typeStr == 'Bike & Dogs') {
                        type = TrailType.bike;
                        withDogs = true;
                      }

                      final typeStatMonth = _user.statsTypes[(
                        tdateAt,
                        type,
                        withDogs,
                      )];

                      if (typeStatMonth != null) {
                        final List<String> dogNames = typeStatMonth.dogsIds
                            .map((dogId) {
                              return _user.dogName(dogId) ?? '';
                            })
                            .where((it) => it.isNotEmpty)
                            .toList();

                        Widget headerDogs = Container();

                        if (dogNames.isNotEmpty) {
                          headerDogs = Container(
                            constraints: BoxConstraints(
                              maxWidth: context.width * 0.58,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.appLR,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.clYellow08,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                bottomLeft: Radius.circular(4),
                              ),
                            ),
                            child: Text(
                              dogNames.join(', '),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.clBlack,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                header,
                                headerDogs,
                              ],
                            ),
                            ProfileRowStat(
                              count: typeStatMonth.count,
                              distance: typeStatMonth.distance,
                              elevation: typeStatMonth.elevation,
                              time: typeStatMonth.time,
                              avgPace: typeStatMonth.avgPace,
                              avgSpeed: typeStatMonth.avgSpeed,
                              showType: false,
                              typeStr: typeStr,
                            ),
                            25.h,
                          ],
                        );
                      }
                    }

                    return Container();
                  }),
                ],
                0.dl,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
