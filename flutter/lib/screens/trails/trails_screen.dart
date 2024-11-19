// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trailcatch/constants.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/device_model.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/skeleton_utils.dart';
import 'package:trailcatch/viewmodels/trail_viewmodel.dart';
import 'package:trailcatch/widgets/buttons/field_button.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/buttons/option_button.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/tcid.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/widget_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class TrailsScreen extends StatefulWidget {
  const TrailsScreen({
    super.key,
    this.trailType,
  });

  final int? trailType;

  @override
  State<TrailsScreen> createState() => _TrailsScreenState();
}

class _TrailsScreenState extends State<TrailsScreen> {
  final ScrollController _ctrl = ScrollController();

  late bool _loadingSkeletons;
  late bool _loadingTop;
  late bool _loadingBottom;
  late bool _loading;
  late bool _noMoreTrails;

  late List<TrailExtModel> _trashTrailsExt;
  late bool _trashMode;

  int? _trailType;
  bool? _withDogs;
  int? _deviceId;

  late bool _refreshProfile;

  @override
  void initState() {
    _loadingSkeletons = false;
    _loadingTop = false;
    _loadingBottom = false;
    _loading = false;
    _noMoreTrails = false;

    _trashTrailsExt = [];

    _trashMode = false;

    _refreshProfile = false;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    context.watch<TrailViewModel>();

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _ctrl.dispose();

    super.dispose();
  }

  Future<void> _fetchTrails({
    required bool doSync,
  }) async {
    if (_loadingBottom) return;

    _noMoreTrails = false;
    _trashTrailsExt = [];
    _trashMode = false;

    if (!_loadingSkeletons && mounted) {
      setState(() {
        _loadingTop = true;
      });
    }

    await fnTry(() async {
      await trailVM.reFetchMyTrails(
        trailType: _trailType,
        withDogs: _withDogs,
        deviceId: _deviceId,
        syncDate: const SyncDate(
          limit: cstFirstLoadItemCount,
        ),
      );
    }, delay: 250.mlsec);

    if (doSync) {
      DateTime to = DateTime.now().subtract(const Duration(
        days: cstTrailsSyncDays,
      ));
      if (trailVM.myTrailsExt.isNotEmpty) {
        to = trailVM.myTrailsExt.first.trail.datetimeAt;
      }

      await deviceVM.reSyncDeviceTrails(
        syncDate: SyncDate(to: to),
        deviceId: _deviceId,
      );
    }

    trailVM.notify();

    _loadingTop = false;
    _loadingSkeletons = false;
  }

  Future<void> _fetchMoreTrails() async {
    if (_loadingTop || _loadingSkeletons) return;
    if (trailVM.myTrailsExt.isEmpty) return;

    _loadingBottom = true;
    trailVM.notify();

    int trailsCountBefore = trailVM.myTrailsExt.length;

    await trailVM.reFetchMyTrails(
      trailType: _trailType,
      withDogs: _withDogs,
      deviceId: _deviceId,
      syncDate: SyncDate(
        from: trailVM.myTrailsExt.last.trail.datetimeAt,
        limit: cstFirstLoadItemCount,
      ),
    );

    int trailsCountAfter = trailVM.myTrailsExt.length;

    _loadingBottom = false;

    if (trailsCountBefore == trailsCountAfter) {
      _noMoreTrails = true;
    }

    trailVM.notify();
  }

  Future<void> _goToDevices() async {
    final isRefresh = await AppRoute.goTo('/devices');

    if (isRefresh ?? false) {
      _refreshProfile = isRefresh;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<TrailExtModel> trailsExt = trailVM.myTrailsExt.where((trailExt) {
      if (!_trashMode && trailExt.trail.inTrash) return false;
      return true;
    }).toList();

    final List<String> lastTrailsNotPubIds = trailVM.lastTrailsNotPubIds();

    final gTrailsExt = groupBy(trailsExt, (trailExt) {
      return '${trailExt.trail.datetimeAt.year}_${trailExt.trail.datetimeAt.month}';
    }).map((key, value) {
      fnSortTrailsDateDesc(value);
      return MapEntry(key, value);
    });

    final String moveToTrashStr = 'Move to Trash / ${fnNumCompact(
      _trashTrailsExt.length,
    )}';

    Widget wBottom = Column(
      children: [
        0.hrr(height: 2),
        10.h,
        Center(
          child: AppSimpleButton(
            width: context.width * AppTheme.appBtnWidth,
            text: moveToTrashStr,
            textColor:
                _trashTrailsExt.isNotEmpty ? AppTheme.clRed : AppTheme.clText04,
            borderColor:
                _trashTrailsExt.isNotEmpty ? AppTheme.clRed : AppTheme.clText04,
            onTap: () {
              if (_trashTrailsExt.isNotEmpty) {
                AppRoute.showPopup(
                  [
                    AppPopupAction(
                      moveToTrashStr,
                      color: AppTheme.clRed,
                      () async {
                        await trailVM.trashTrails(_trashTrailsExt);

                        setState(() {
                          _refreshProfile = true;

                          _trashTrailsExt = [];
                        });
                      },
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );

    Widget wBottomSync = Column(
      children: [
        0.hrr(height: 2),
        10.h,
        Center(
          child: AppSimpleButton(
            width: context.width * AppTheme.appBtnWidth,
            text: 'Connect Device / *.FIT',
            textColor: AppTheme.clYellow,
            borderColor: AppTheme.clYellow,
            onTap: _goToDevices,
          ),
        ),
      ],
    );

    bool isEmpt = _deviceId == null &&
        _trailType == null &&
        _withDogs == null &&
        trailVM.myTrailsExt.isEmpty &&
        !_loading &&
        !_loadingBottom &&
        !_loadingSkeletons &&
        !_loadingTop;

    return AppSimpleScaffold(
      title: 'Trails',
      loadingTop: _loadingTop,
      loadingBottom: _loadingBottom,
      loading: _loading,
      scrollCtrl: _ctrl,
      physics: const AlwaysScrollableScrollPhysics(),
      onRefresh: () => _fetchTrails(doSync: true),
      onLoadMore: _noMoreTrails ? null : _fetchMoreTrails,
      onBack: () async {
        deviceVM.stopTrailsSync = true;
        AppRoute.goBack(_refreshProfile);
      },
      loadMoreAnimate: true,
      wBottom: isEmpt
          ? wBottomSync
          : (_trashMode && _trashTrailsExt.isNotEmpty ? wBottom : null),
      actions: [
        AppWidgetButton(
          onTap: () async {
            setState(() {
              _trashMode = !_trashMode;
              _trashTrailsExt = [];
            });
          },
          child: Icon(
            Icons.delete_sweep_outlined,
            color: _trashMode ? AppTheme.clRed : AppTheme.clText,
            size: 27,
          ),
        ),
        AppWidgetButton(
          onTap: _goToDevices,
          child: Icon(
            Icons.devices_other_outlined,
            color: isEmpt ? AppTheme.clYellow : AppTheme.clText,
            size: 26,
          ),
        ),
      ],
      child: Column(
        children: [
          Container(
            color: AppTheme.clBlack,
            padding: const EdgeInsets.only(
              left: 10,
              right: AppTheme.appLR,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: AppFieldButton(
                    text: DeviceId.formatToStr(_deviceId),
                    down: true,
                    onTap: () {
                      AppRoute.showPopup(
                        [
                          for (var deviceStr in DeviceId.allStr)
                            AppPopupAction(
                              deviceStr,
                              selected:
                                  _deviceId == DeviceId.formatToId(deviceStr),
                              () async {
                                int? deviceId = DeviceId.formatToId(deviceStr);

                                if (_deviceId != deviceId) {
                                  trailVM.clearMyTrailsExt();

                                  setState(() {
                                    _loadingSkeletons = true;
                                    _deviceId = deviceId;
                                  });

                                  fnHaptic();

                                  await _fetchTrails(doSync: false);
                                }
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: AppOptionButton(
                    value: TrailType.formatToStr(_trailType),
                    opts: TrailType.allStr,
                    textColor: AppTheme.clText07,
                    onValueChanged: (value) async {
                      final int? trailType = TrailType.formatToType(value);

                      if (trailType != _trailType) {
                        trailVM.clearMyTrailsExt();

                        setState(() {
                          _loadingSkeletons = true;
                          _trailType = trailType;
                        });

                        fnHaptic();

                        _fetchTrails(doSync: false);
                      }
                    },
                  ),
                ),
                5.w,
                AppGestureButton(
                  onTap: () {
                    trailVM.clearMyTrailsExt();

                    setState(() {
                      _loadingSkeletons = true;
                      _withDogs = _withDogs == null ? true : null;
                    });

                    fnHaptic();

                    _fetchTrails(doSync: false);
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
          if (_loadingSkeletons) ...[
            fnTrailGridSkeletons(context),
            10.h,
          ] else ...[
            if (gTrailsExt.isEmpty)
              fnTrailGridSkeletons(context, true)
            else
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  0.hrr(height: 10, color: AppTheme.clBackground),
                  for (var gTrailExt in gTrailsExt.values)
                    Container(
                      color: AppTheme.clBackground,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.appLR,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Trails: ${gTrailExt.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.clText08,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                10.w,
                                Text(
                                  gTrailExt.first.trail.datetimeAt.toDate(
                                    isY2: true,
                                    isD: false,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.clText08,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          5.hrr(
                              height: 0.5, color: AppTheme.clText02, padLR: 15),
                          10.h,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: _trashMode ? 10 : 15,
                            ),
                            child: GridView.count(
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: 4,
                              mainAxisSpacing: _trashMode ? 10 : 15,
                              crossAxisSpacing: _trashMode ? 0 : 10,
                              children: [
                                for (var trailExt in gTrailExt)
                                  Builder(builder: (context) {
                                    Color? labelColor;
                                    Color? borderColor;

                                    if (trailExt.trail.notPub &&
                                        lastTrailsNotPubIds
                                            .contains(trailExt.trail.trailId)) {
                                      labelColor = AppTheme.clYellow;
                                      borderColor = AppTheme.clYellow;
                                    }

                                    Widget wTCID = AppTCID(
                                      trail: trailExt.trail,
                                      labelColor: labelColor,
                                      borderColor: borderColor,
                                    );

                                    if (_trashMode) {
                                      Color? selectColor;

                                      if (trailExt.trail.inTrash) {
                                        selectColor = AppTheme.clTransparent;
                                      } else {
                                        selectColor =
                                            _trashTrailsExt.contains(trailExt)
                                                ? AppTheme.clRed
                                                : AppTheme.clText03;
                                      }

                                      wTCID = Column(
                                        children: [
                                          AppTCID(
                                            height: 75,
                                            trail: trailExt.trail,
                                            labelColor: labelColor,
                                            borderColor: borderColor,
                                          ),
                                          6.h,
                                          Container(
                                            height: 3,
                                            width: 55,
                                            decoration: BoxDecoration(
                                              color: selectColor,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(8)),
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    return AppGestureButton(
                                      onTap: () async {
                                        if (_trashMode &&
                                            !trailExt.trail.inTrash) {
                                          setState(() {
                                            if (_trashTrailsExt
                                                .contains(trailExt)) {
                                              _trashTrailsExt.remove(trailExt);
                                            } else {
                                              _trashTrailsExt.add(trailExt);
                                            }
                                          });
                                        } else {
                                          final isRefresh = await AppRoute.goTo(
                                            '/trail_card',
                                            args: {
                                              'trailExt': trailExt,
                                            },
                                          );

                                          if (isRefresh ?? false) {
                                            _refreshProfile = isRefresh;
                                          }
                                        }
                                      },
                                      child: wTCID,
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
