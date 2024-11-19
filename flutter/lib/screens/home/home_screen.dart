// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trailcatch/constants.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/screens/trails/widgets/trail_card.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/skeleton_utils.dart';
import 'package:trailcatch/viewmodels/app_viewmodel.dart';
import 'package:trailcatch/viewmodels/trail_viewmodel.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/buttons/option_button.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/widget_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final ScrollController _ctrl = ScrollController();

  late int _filtrType;

  late bool _loadingSkeletons;
  late bool _loadingTop;
  late bool _loadingBottom;

  @override
  void initState() {
    _filtrType = 1;

    _loadingSkeletons = false;
    _loadingTop = false;
    _loadingBottom = false;

    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    context.watch<AppViewModel>();
    context.watch<TrailViewModel>();

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _ctrl.dispose();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      appVM.reFetchSettings().then((_) {
        appVM.notify();
      });
    }
  }

  Future<void> _fetchTrails() async {
    if (_loadingBottom) return;

    if (mounted) setState(() => _loadingTop = true);

    await Future.wait([
      trailVM.reFetchFeedTrails(
        syncDate: const SyncDate(
          limit: cstFirstLoadItemCount,
        ),
        doClear: true,
      ),
      trailVM.reFetchFltFeedTrails(
        syncDate: const SyncDate(
          limit: cstFirstLoadNearItemCount,
        ),
        doClear: true,
      ),
    ]);

    if (mounted) setState(() => _loadingTop = false);
  }

  Future<void> _fetchMoreTrails() async {
    if (_loadingTop) return;

    if (mounted) setState(() => _loadingBottom = true);

    await Future.wait([
      if (_filtrType == 1)
        trailVM.reFetchFeedTrails(
          syncDate: SyncDate(
            from: trailVM.feedTrailsExt.lastOrNull?.trail.datetimeAt,
            limit: cstFirstLoadItemCount,
          ),
        )
      else if (_filtrType == 2)
        trailVM.reFetchFltFeedTrails(
          syncDate: SyncDate(
            offset: trailVM.nearTrailsExt.length,
            limit: cstFirstLoadNearItemCount,
          ),
        ),
    ]);

    if (mounted) setState(() => _loadingBottom = false);
  }

  Future<void> _openFilters() async {
    final bool? isChanged = await AppRoute.goSheetTo('/trail_filters', args: {
      'showFltStranges': false,
    });

    if (isChanged ?? false) {
      setState(() => _loadingSkeletons = true);

      setState(() {
        _filtrType = 2;
      });

      await _fetchTrails();

      setState(() => _loadingSkeletons = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!appVM.isUserExists) {
      return fnRootWidgetError(context, title: 'TrailCatch');
    }

    double unrdwd = 40;
    if (appVM.settings.unreadNotifs > 9) {
      unrdwd = 45;
    }
    if (appVM.settings.unreadNotifs > 99) {
      unrdwd = 50;
    }

    late String unreadNotifs;
    if (appVM.settings.unreadNotifs <= 99) {
      unreadNotifs = '${appVM.settings.unreadNotifs}';
    } else {
      unreadNotifs = '99+';
    }

    List<TrailExtModel> trailsExt =
        _filtrType == 1 ? trailVM.feedTrailsExt : trailVM.feedFltTrailsExt;

    return AppSimpleScaffold(
      title: 'TrailCatch',
      hideBack: true,
      loadingTop: _loadingTop || trailVM.loadingTop,
      loadingBottom: _loadingBottom,
      scrollCtrl: _ctrl,
      physics: const AlwaysScrollableScrollPhysics(),
      onRefresh: () async {
        await _fetchTrails();

        await appVM.reFetchSettings();
        appVM.notify();
      },
      onLoadMore: _fetchMoreTrails,
      loadMoreAnimate: true,
      onTapTitle: _openFilters,
      actions: [
        AppWidgetButton(
          onTap: () {
            AppRoute.goTo('/notifications');
          },
          child: SizedBox(
            width: unrdwd,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Icon(
                    Icons.markunread_mailbox_outlined,
                    color: appVM.settings.unreadNotifs > 0
                        ? AppTheme.clYellow
                        : AppTheme.clText,
                    size: 26,
                  ),
                ),
                if (appVM.settings.unreadNotifs > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Text(
                      unreadNotifs,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.clYellow,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        AppWidgetButton(
          onTap: () async {
            AppRoute.goSheetTo('/radar_search');
          },
          child: const Icon(
            Icons.person_search,
            color: AppTheme.clText,
            size: 28,
          ),
        ),
      ],
      children: [
        Container(
          color: AppTheme.clBlack,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.appLR,
            vertical: 2,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: AppOptionButton(
                  value: _filtrType == 1 ? 'Subscribed To' : 'Filtered',
                  opts: const ['Subscribed To', 'Filtered'],
                  textColor: AppTheme.clText07,
                  onValueChanged: (value) async {
                    if (value == null) return;

                    if (value == 'Subscribed To' && _filtrType != 1) {
                      setState(() {
                        _filtrType = 1;
                      });
                    } else if (value == 'Filtered' && _filtrType != 2) {
                      setState(() {
                        _filtrType = 2;
                      });
                    }

                    fnHaptic();
                  },
                ),
              ),
              10.w,
              AppGestureButton(
                onTap: _openFilters,
                child: Container(
                  color: AppTheme.clBlack,
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: trailVM.trailFilters.isEmpty
                        ? AppTheme.clText07
                        : AppTheme.clYellow,
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            0.hrr(height: 3, color: AppTheme.clBackground),
            if (_loadingSkeletons) ...[
              fnTrailSkeleton(context),
              10.h,
            ] else ...[
              if (trailsExt.isEmpty) ...[
                fnTrailSkeleton(context, true),
                10.h,
              ] else
                for (var trailExt in trailsExt)
                  Column(
                    children: [
                      TrailCard(
                        trailExt: trailExt,
                        onTap: () async {
                          await AppRoute.goTo('/trail_card', args: {
                            'trailExt': trailExt,
                          });
                        },
                      ),
                      if (trailsExt.last != trailExt) 0.hrr(height: 5),
                    ],
                  ),
            ],
          ],
        ),
      ],
    );
  }
}
