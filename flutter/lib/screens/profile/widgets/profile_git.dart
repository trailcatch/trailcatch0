// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/statistic_model.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/screens/profile/widgets/profile_row_stat.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/viewmodels/app_viewmodel.dart';
import 'package:trailcatch/viewmodels/trail_viewmodel.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';

class ProfileGit extends StatefulWidget {
  const ProfileGit({
    super.key,
    required this.user,
    this.showStats = true,
    this.mpage,
  });

  final UserModel user;
  final bool showStats;
  final int? mpage;

  @override
  State<ProfileGit> createState() => _ProfileGitState();
}

class _ProfileGitState extends State<ProfileGit> {
  late PageController _statCtrl;
  late int _page;

  late List<StatisticMonthModel> _statMonths;

  @override
  void initState() {
    _reStatMonths();

    _page = 0;
    if (widget.mpage == null) {
      for (var statMonth in _statMonths) {
        if (DateUtils.isSameMonth(statMonth.dateAt, DateTime.now())) {
          break;
        } else {
          _page += 1;
        }
      }
    } else {
      _page = widget.mpage!;
    }

    _statCtrl = PageController(initialPage: _page, viewportFraction: 0.3);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    context.watch<AppViewModel>();
    context.watch<TrailViewModel>();

    _reStatMonths();

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _statCtrl.dispose();

    super.dispose();
  }

  void _reStatMonths() {
    _statMonths = widget.user.statsGit.values.fold([], (acc, it) {
      return acc..addAll(it);
    });
  }

  @override
  Widget build(BuildContext context) {
    final statMonth = _statMonths[_page];

    final isYearP = widget.user.statsGit.keys.contains(
      statMonth.dateAt.year - 1,
    );
    final isYearN = widget.user.statsGit.keys.contains(
      statMonth.dateAt.year + 1,
    );

    return Container(
      color: AppTheme.clBackground,
      width: context.width,
      child: Column(
        children: [
          10.h,
          if (widget.showStats) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${statMonth.dateAt.year - 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isYearP ? AppTheme.clText : AppTheme.clText03,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    statMonth.dateAt.toMonthYear(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.clYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${statMonth.dateAt.year + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isYearN ? AppTheme.clText : AppTheme.clText03,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            5.hrr(height: 0.5, color: AppTheme.clText02, padLR: 15),
            5.h,
            AppGestureButton(
              onTap: () {
                AppRoute.goTo('/profile_statistics', args: {
                  'user': widget.user,
                  'year': statMonth.dateAt.year,
                });
              },
              child: ProfileRowStat(
                count: statMonth.count,
                distance: statMonth.distance,
                elevation: statMonth.elevation,
                time: statMonth.time,
                avgPace: statMonth.avgPace,
                avgSpeed: statMonth.avgSpeed,
                hideAvg: true,
                sepTrails: true,
              ),
            ),
            0.dl,
          ] else
            5.h,
          SizedBox(
            width: context.width,
            height: 135,
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 2,
                    width: 115,
                    decoration: const BoxDecoration(
                      color: AppTheme.clYellow,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PageView(
                    controller: _statCtrl,
                    onPageChanged: (int page) {
                      setState(() {
                        _page = page;
                      });
                    },
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (var it0 in _statMonths)
                        AppGestureButton(
                          onTap: () {
                            if (!widget.showStats) return;
                            if (it0.count == 0) return;

                            AppRoute.goSheetTo(
                              '/profile_month_trails',
                              args: {
                                'user': widget.user,
                                'monthAt': it0.dateAt,
                              },
                            );
                          },
                          child: ProfileGitItem(
                            statMonth: it0,
                            showY2: !widget.showStats,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileGitItem extends StatelessWidget {
  const ProfileGitItem({
    super.key,
    required this.statMonth,
    this.showY2 = false,
  });

  final StatisticMonthModel statMonth;
  final bool showY2;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      statMonth.dateAt.year,
      statMonth.dateAt.month,
    );
    final int offset = fnFirstDayOffset(
      statMonth.dateAt.year,
      statMonth.dateAt.month,
      1,
    );

    List<String> daysOfWeek0 = [];
    if (!appVM.isUserExists) {
      // just for demo screen only
      daysOfWeek0 = fnDaysOfWeek(1, 'en');
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: AppTheme.clBackground,
      child: Column(
        children: [
          Expanded(
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1,
              children: List.generate(49, (index) {
                Color color = AppTheme.clBlack;

                bool md = (index - 6) >= offset + 1;
                if ((index - 6) > (daysInMonth + offset)) {
                  md = false;
                }

                if (md) {
                  if (statMonth.days.contains((index - 6 - offset))) {
                    color = AppTheme.clYellow;
                  } else {
                    color = AppTheme.clText005;
                  }
                }

                if (index >= 0 && index <= 6) {
                  return Container(
                    alignment: Alignment.center,
                    child: Text(
                      appVM.isUserExists
                          ? appVM.settings.daysOfWeek1ch[index]
                          : daysOfWeek0[index],
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            height: 20,
            child: Text(
              showY2
                  ? statMonth.dateAt.toMonthYear(isY2: true, isM3: true)
                  : statMonth.dateAt.toMonth(isM3: true),
              style: const TextStyle(
                fontSize: 12,
                height: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
