// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import 'package:trailcatch/constants.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/screens/trails/widgets/trail_card.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/skeleton_utils.dart';
import 'package:trailcatch/viewmodels/app_viewmodel.dart';
import 'package:trailcatch/screens/profile/widgets/profile_bio.dart';
import 'package:trailcatch/screens/profile/widgets/profile_btns.dart';
import 'package:trailcatch/screens/profile/widgets/profile_git.dart';
import 'package:trailcatch/screens/profile/widgets/profile_numbers.dart';
import 'package:trailcatch/screens/profile/widgets/profile_user_dogs.dart';
import 'package:trailcatch/viewmodels/trail_viewmodel.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/buttons/option_button.dart';
import 'package:trailcatch/widgets/buttons/widget_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.user,
    this.userId,
  });

  final UserModel? user;
  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _ctrl = ScrollController();

  late bool _loadingSkeletons;
  late bool _loadingTop;
  late bool _loadingBottom;
  late bool _noMoreTrails;

  late List<TrailExtModel> _trailsExt;

  late bool _loadingUser;
  late UserModel _user;

  int? _trailType;
  bool? _withDogs;

  @override
  void initState() {
    _loadingSkeletons = true;
    _loadingTop = false;
    _loadingBottom = false;
    _noMoreTrails = false;

    _trailsExt = [];

    _loadingUser = false;
    if (widget.user == null && widget.userId != null) {
      _loadingUser = true;

      userServ.fnUsersFetch(userId: widget.userId!).then(
        (UserModel? user0) async {
          if (user0 != null) {
            _loadingUser = false;
            _user = user0;

            scheduleMicrotask(
              () => _fetchTrails(fetchTrails: true, doSync: true),
            );
          } else {
            AppRoute.goBack();

            throw AppError(
              message: 'Account not found.',
              code: AppErrorCode.accountNotFound,
            );
          }
        },
      );
    } else {
      _user = widget.user ?? appVM.user;

      scheduleMicrotask(
        () => _fetchTrails(fetchTrails: true, doSync: true),
      );
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    context.watch<AppViewModel>();
    context.watch<TrailViewModel>();

    if (!_loadingUser) {
      if (appVM.isUserExists && _user.isMe) {
        _user = appVM.user;
      }
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _ctrl.dispose();

    super.dispose();
  }

  Future<void> _fetchTrails({
    bool fetchTrails = false,
    bool fetchUser = false,
    bool doSync = false,
  }) async {
    if (_loadingBottom) return;

    if (!_loadingSkeletons && mounted) {
      setState(() {
        _loadingTop = true;
      });
    }

    if (fetchTrails) {
      _noMoreTrails = false;

      await fnTry(() async {
        _trailsExt = await trailServ.fnTrailsFetch(
          userId: _user.userId,
          type: _trailType,
          withDogs: _withDogs,
          inTrashNotPub: false,
          syncDate: const SyncDate(
            limit: cstFirstLoadItemCount,
          ),
        );
      }, delay: 250.mlsec);
    }

    if (fetchUser) {
      if (_user.isMe) {
        await appVM.reFetchMyself();
        _user = appVM.user;

        appVM.notify();
        notifVM.reFetchNotifs();
      } else {
        final user0 = await userServ.fnUsersFetch(userId: _user.userId);
        _user = user0 ?? _user;
      }

      if (mounted) {
        setState(() {});
      }
    }

    if (_user.isMe && doSync) {
      if (trailVM.myTrailsExt.isEmpty) {
        await trailVM.reFetchMyTrails(
          syncDate: const SyncDate(
            limit: cstFirstLoadItemCount,
          ),
        );
      }

      DateTime to = DateTime.now().subtract(const Duration(
        days: cstProfileSyncDays,
      ));
      if (trailVM.myTrailsExt.isNotEmpty) {
        to = trailVM.myTrailsExt.first.trail.datetimeAt;
      }

      await deviceVM.reSyncDeviceTrails(
        syncDate: SyncDate(to: to),
      );
    }

    if (mounted) {
      setState(() {
        _loadingTop = false;
        _loadingSkeletons = false;
      });
    }
  }

  Future<void> _fetchMoreTrails() async {
    if (_loadingTop || _loadingSkeletons) return;
    if (_trailsExt.isEmpty) return;

    setState(() {
      _loadingBottom = true;
    });

    final int trailsCountBefore = trailVM.myTrailsExt.length;

    final trailsExt0 = await trailServ.fnTrailsFetch(
      userId: _user.userId,
      type: _trailType,
      withDogs: _withDogs,
      inTrashNotPub: false,
      syncDate: SyncDate(
        from: _trailsExt.last.trail.datetimeAt,
        limit: cstFirstLoadItemCount,
      ),
    );

    _trailsExt.addAll(trailsExt0);

    final int trailsCountAfter = trailVM.myTrailsExt.length;

    setState(() {
      _loadingBottom = false;

      if (trailsCountBefore == trailsCountAfter) {
        _noMoreTrails = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!appVM.isUserExists) {
      return fnRootWidgetError(context, title: 'Profile');
    }

    if (_loadingUser) {
      return AppSimpleScaffold(
        title: 'Profile',
        wBottom: Container(
          padding: const EdgeInsets.only(bottom: 10),
          child: Image.asset(
            'assets/***/app_icon_tr.png',
            scale: 5,
            cacheHeight: 139,
            cacheWidth: 132,
          ),
        ),
        children: [
          30.h,
          const SizedBox(
            height: 50,
            child: LoadingIndicator(
              pause: false,
              indicatorType: Indicator.lineScalePulseOut,
              colors: [
                AppTheme.clYellow,
                AppTheme.clText,
                AppTheme.clRed,
                AppTheme.clText,
                AppTheme.clYellow,
              ],
              backgroundColor: AppTheme.clBackground,
              pathBackgroundColor: AppTheme.clBackground,
            ),
          ),
        ],
      );
    }

    _trailsExt = _trailsExt
        .where((trl) => !trl.trail.inTrash && !trl.trail.notPub)
        .toList();

    return AppSimpleScaffold(
      title: 'Profile',
      hideBack: widget.user == null && widget.userId == null,
      loadingTop: _loadingTop || trailVM.loadingTop,
      loadingBottom: _loadingBottom,
      scrollCtrl: _ctrl,
      physics: const AlwaysScrollableScrollPhysics(),
      onRefresh: () async {
        _fetchTrails(fetchUser: true, doSync: true);
      },
      onLoadMore: _noMoreTrails ? null : _fetchMoreTrails,
      loadMoreAnimate: true,
      actions: [
        AppWidgetButton(
          onTap: () {
            AppRoute.goTo('/profile_statistics', args: {
              'user': _user,
            });
          },
          child: const Icon(
            Icons.analytics_outlined,
            color: AppTheme.clText,
            size: 26,
          ),
        ),
        if (_user.isMe && widget.user == null && widget.userId == null)
          AppWidgetButton(
            onTap: Scaffold.of(context).openEndDrawer,
            child: const Icon(
              Icons.menu_open,
              color: AppTheme.clText,
              size: 29,
            ),
          ),
      ],
      children: [
        0.hrr(height: 1.5),
        ProfileUserAndDogs(user: _user),
        0.hrr(height: 3),
        ProfileNumbers(user: _user),
        0.hrr(height: 8, color: AppTheme.clBackground),
        ProfileBio(user: _user),
        ProfileBtns(
          user: _user,
          fromRoot: widget.user == null && widget.userId == null,
          doRefresh: () {
            setState(() {
              _loadingSkeletons = true;
            });

            _fetchTrails(fetchTrails: true, fetchUser: true);
          },
        ),
        ProfileGit(user: _user),
        0.hrr(height: 8, color: AppTheme.clBackground),
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
                  value: TrailType.formatToStr(_trailType),
                  opts: TrailType.allStr,
                  textColor: AppTheme.clText07,
                  onValueChanged: (value) async {
                    final int? trailType = TrailType.formatToType(value);

                    if (trailType != _trailType) {
                      setState(() {
                        _loadingSkeletons = true;
                        _trailType = trailType;
                      });

                      fnHaptic();

                      _fetchTrails(fetchTrails: true);
                    }
                  },
                ),
              ),
              10.w,
              AppGestureButton(
                onTap: () {
                  setState(() {
                    _loadingSkeletons = true;
                    _withDogs = _withDogs == null ? true : null;
                  });

                  fnHaptic();

                  _fetchTrails(fetchTrails: true);
                },
                child: Container(
                  color: AppTheme.clBlack,
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.pets,
                    size: 20,
                    color: _withDogs != null
                        ? AppTheme.clYellow
                        : AppTheme.clText07,
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
              if (_trailsExt.isEmpty) ...[
                fnTrailSkeleton(context, true),
                10.h,
              ] else
                for (var trailExt in _trailsExt)
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
                      if (_trailsExt.last != trailExt) 0.hrr(height: 3),
                    ],
                  ),
            ],
          ],
        ),
      ],
    );
  }
}
