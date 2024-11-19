// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:trailcatch/constants.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/screens/profile/widgets/profile_rlship.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/skeleton_utils.dart';
import 'package:trailcatch/widgets/buttons/option_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class ProfileRlshipScreen extends StatefulWidget {
  const ProfileRlshipScreen({
    super.key,
    required this.user,
    required this.subscriptions,
    required this.hiddens,
  });

  final UserModel user;
  final bool subscriptions;
  final bool hiddens;

  @override
  State<ProfileRlshipScreen> createState() => _ProfileRlshipScreenState();
}

class _ProfileRlshipScreenState extends State<ProfileRlshipScreen> {
  final ScrollController _ctrl = ScrollController();

  late bool _loadingSkeletons;
  late bool _loadingTop;
  late bool _loadingBottom;

  late int _rlship;

  late UserModel _user;

  final List<TrailExtModel> _trailExts01 = [];
  final List<TrailExtModel> _trailExts02 = [];

  @override
  void initState() {
    _loadingSkeletons = true;
    _loadingTop = false;
    _loadingBottom = false;

    _rlship = 1;
    if (widget.subscriptions) {
      _rlship = 2;
    } else if (widget.hiddens) {
      _rlship = 0;
    }

    _user = widget.user;

    scheduleMicrotask(_fetchRlships);

    trailVM.reFetchRlship0 =
        () async => await _fetchRlships(doClear: true, fetchUser: true);

    super.initState();
  }

  Future<void> _fetchRlships({
    bool doClear = true,
    bool fetchUser = false,
  }) async {
    if (!_loadingSkeletons && mounted && !_loadingBottom) {
      setState(() => _loadingTop = true);
    }

    await fnTry(() async {
      if (doClear) {
        _trailExts01.clear();
        _trailExts02.clear();
      }

      if (fetchUser) {
        final user0 = await userServ.fnUsersFetch(userId: _user.userId);
        if (user0 != null) {
          _user = user0;
        }
      }

      if (!widget.hiddens) {
        final trailExts01 = await trailServ.fnTrailsFetchSubscribers(
          userId: _user.userId,
          syncDate: SyncDate(
            limit: cstFirstLoadItemCount,
            from: _trailExts01.lastOrNull?.trail.datetimeAt,
          ),
        );

        final List<String> userIds01 =
            _trailExts01.map((trl) => trl.user.userId).toList();

        for (var trailExt01 in trailExts01) {
          if (!userIds01.contains(trailExt01.user.userId)) {
            _trailExts01.add(trailExt01);
          }
        }

        final trailExts02 = await trailServ.fnTrailsFetchSubscriptions(
          userId: _user.userId,
          syncDate: SyncDate(
            limit: cstFirstLoadItemCount,
            from: _trailExts02.lastOrNull?.trail.datetimeAt,
          ),
        );

        final List<String> userIds02 =
            _trailExts02.map((trl) => trl.user.userId).toList();

        for (var trailExt02 in trailExts02) {
          if (!userIds02.contains(trailExt02.user.userId)) {
            _trailExts02.add(trailExt02);
          }
        }
      } else {
        final trailExts01 = await trailServ.fnTrailsFetchSubscriptions(
          userId: _user.userId,
          hiddens: true,
          syncDate: SyncDate(
            limit: cstFirstLoadItemCount,
            from: _trailExts01.lastOrNull?.trail.datetimeAt,
          ),
        );

        final List<String> userIds01 =
            _trailExts01.map((trl) => trl.user.userId).toList();

        for (var trailExt01 in trailExts01) {
          if (!userIds01.contains(trailExt01.user.userId)) {
            _trailExts01.add(trailExt01);
          }
        }
      }
    }, delay: 250.mlsec);

    if (mounted) {
      setState(() {
        _loadingTop = false;
        _loadingBottom = false;
        _loadingSkeletons = false;
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Connections';
    String noFound = 'No subscribers found';

    List<TrailExtModel> trailExts = [];
    if (widget.hiddens || _rlship == 1) {
      trailExts = _trailExts01;

      if (widget.hiddens) {
        noFound = 'No hiddens found';
        title = 'Hiddens';
      }
    } else if (_rlship == 2) {
      trailExts = _trailExts02;

      noFound = 'No subscriptions found';
    }

    String subscrStr01 = 'Subscribers / ${fnNumCompact(
      _user.subscribers,
    )}';

    String subscrStr02 = 'Subscriptions / ${fnNumCompact(
      _user.subscriptions,
    )}';

    return AppSimpleScaffold(
      title: title,
      loadingTop: _loadingTop,
      loadingBottom: _loadingBottom,
      scrollCtrl: _ctrl,
      physics: const AlwaysScrollableScrollPhysics(),
      onRefresh: _fetchRlships,
      onLoadMore: () async {
        if (mounted) setState(() => _loadingBottom = true);

        await _fetchRlships(doClear: false);
      },
      children: [
        if (!widget.hiddens)
          Container(
            color: AppTheme.clBackground,
            child: Column(
              children: [
                8.h,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.appLR,
                  ),
                  child: AppOptionButton(
                    value: _rlship == 1 ? subscrStr01 : subscrStr02,
                    opts: [subscrStr01, subscrStr02],
                    onValueChanged: (value) async {
                      if (value == subscrStr01 && _rlship != 1) {
                        setState(() {
                          _rlship = 1;
                        });
                      } else if (value == subscrStr02 && _rlship != 2) {
                        setState(() {
                          _rlship = 2;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        if (_loadingSkeletons) ...[
          10.h,
          fnUserSkeleton(context),
        ] else ...[
          if (trailExts.isEmpty)
            Container(
              width: context.width,
              height: 150,
              color: AppTheme.clBackground,
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Container(
                alignment: Alignment.topCenter,
                child: Text(
                  noFound,
                  style: const TextStyle(
                    color: AppTheme.clText08,
                  ),
                ),
              ),
            )
          else
            Container(
              color: AppTheme.clBackground,
              child: Column(
                children: [
                  10.h,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.sort_by_alpha_rounded,
                        size: 15,
                        color: AppTheme.clText05,
                      ),
                      6.w,
                      const Text(
                        'Sorted by trail date',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.clText05,
                        ),
                      ),
                    ],
                  ),
                  10.h,
                  for (var trailExt in trailExts) ...[
                    ProfileRlship(trailExt: trailExt),
                    12.hrr(
                      height: 1.5,
                      color: AppTheme.clBlack,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ],
    );
  }
}
