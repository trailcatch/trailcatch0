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
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/screens/radar/widgets/radar_chart.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/location_utils.dart';
import 'package:trailcatch/viewmodels/app_viewmodel.dart';
import 'package:trailcatch/viewmodels/trail_viewmodel.dart';
import 'package:trailcatch/widgets/avatar_image.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/buttons/widget_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';
import 'package:trailcatch/widgets/tcid.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({
    super.key,
  });

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  late int _page;

  late final PageController _radarCtrl0;
  late final PageController _radarCtrl;
  late final PageController _trlsCtrl;

  TrailExtModel? _trailExt;
  late List<List<dynamic>> _trailDist8th;
  String? _ageGroupStr;

  bool _lockHidding0 = false;
  bool _hidding0 = false;

  bool _lockHidding = false;
  bool _hidding = false;

  bool _loading = false;
  bool _rotate = false;

  bool _yourCityShown = false;

  @override
  void initState() {
    _page = 0;

    _radarCtrl0 = PageController(initialPage: 0);
    _radarCtrl = PageController(initialPage: 0);
    _trlsCtrl = PageController(viewportFraction: 0.192, initialPage: 0);

    _setTrailExt(trailVM.nearTrailsExt.elementAtOrNull(0));

    _radarCtrl0.addListener(() async {
      double pixels = _radarCtrl0.position.pixels;

      if (pixels < -100 && !_lockHidding0) {
        _lockHidding0 = true;

        setState(() {
          _hidding0 = true;
        });

        Future.delayed(350.mlsec, _fetchTrails);
      }
    });

    _radarCtrl.addListener(() async {
      double pixels = _radarCtrl.position.pixels;
      double maxpix = _radarCtrl.position.maxScrollExtent;

      if (pixels < -100 && !_lockHidding0) {
        _lockHidding0 = true;

        setState(() {
          _hidding0 = true;
        });

        Future.delayed(350.mlsec, _fetchTrails);
      } else if (pixels > maxpix + 70 && !_lockHidding) {
        _lockHidding = true;

        setState(() {
          _hidding = true;
        });

        Future.delayed(350.mlsec, _fetchMoreTrails);
      }
    });

    appVM.reInitRadarPos = () {
      if (appVM.yourCity == null) {
        if (!_yourCityShown) {
          _yourCityShown = true;

          Future.delayed(250.mlsec, () {
            AppRoute.goSheetTo('/radar_empty_your_city');
          });
        }
      } else if (_page == 0 && trailVM.nearTrailsExt.length >= 3) {
        _radarCtrl.animateToPage(
          2,
          duration: 500.mlsec,
          curve: Curves.linear,
        );
      }
    };

    trailVM.reFetchRadar0 = () async => await _fetchTrails(doClear: true);

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
    _radarCtrl.dispose();
    _trlsCtrl.dispose();

    super.dispose();
  }

  Future<void> _fetchTrails({bool doClear = false}) async {
    if (mounted) {
      setState(() {
        _loading = true;
        _rotate = true;
      });
    }

    fnHaptic();

    await fnTry(() async {
      await trailVM.reFetchNearestTrails(
        syncDate: const SyncDate(
          limit: cstFirstLoadNearItemCount,
        ),
        doClear: doClear,
      );
    }, delay: 1000.mlsec);

    _setTrailExt(trailVM.nearTrailsExt.elementAtOrNull(0));

    Future.delayed(const Duration(milliseconds: 350), () {
      _radarCtrl.animateToPage(
        0,
        duration: 500.mlsec,
        curve: Curves.linear,
      );

      _trlsCtrl.animateToPage(
        0,
        duration: 500.mlsec,
        curve: Curves.linear,
      );
    });

    if (mounted) {
      setState(() {
        _page = 0;
        _loading = false;
        _hidding0 = false;
        _hidding = false;
        _rotate = false;
        _lockHidding = false;
        _lockHidding0 = false;
      });
    }
  }

  Future<void> _fetchMoreTrails() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _rotate = true;
      });
    }

    fnHaptic();

    int pos = trailVM.nearTrailsExt.length;
    await fnTry(() async {
      await trailVM.reFetchNearestTrails(
        syncDate: SyncDate(
          offset: trailVM.nearTrailsExt.length,
          limit: cstFirstLoadNearItemCount,
        ),
      );
    }, delay: 1000.mlsec);

    if (mounted) {
      setState(() {
        _loading = false;
        _hidding0 = false;
        _hidding = false;
        _rotate = false;
        _lockHidding = false;
        _lockHidding0 = false;
      });

      if (trailVM.nearTrailsExt.length > pos) {
        _radarCtrl.animateToPage(
          pos,
          duration: 500.mlsec,
          curve: Curves.linear,
        );
      }
    }
  }

  void _setTrailExt(TrailExtModel? trailExt) {
    _trailDist8th = cstDist8thEmpty;

    _trailExt = trailExt;
    if (_trailExt == null) return;

    _reTrailDist8th(cstDefRadarMaxDistance);

    _ageGroupStr = fnAgeGroup(
      gender: _trailExt!.user.gender,
      age: _trailExt!.user.age,
    );
  }

  void _reTrailDist8th(double shakeDist) {
    if (_trailExt == null) return;

    if (_trailExt!.trail.deviceGeopoints != null) {
      _trailDist8th = fnBuildTrailDist8th(
        _trailExt!.trail.deviceGeopoints!,
        shakeDist,
      );
    }
  }

  Future<void> _openFilters() async {
    final bool? isChanged = await AppRoute.goSheetTo('/trail_filters', args: {
      'showFltStranges': true,
    });

    if (isChanged ?? false) {
      _lockHidding0 = true;

      setState(() {
        _hidding0 = true;
      });

      await Future.delayed(350.mlsec);
      await _fetchTrails(doClear: true);

      trailVM.reFetchFltFeedTrails(
        syncDate: const SyncDate(
          limit: cstFirstLoadNearItemCount,
        ),
        doClear: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!appVM.isUserExists) {
      return fnRootWidgetError(context, title: 'Nearby Your City');
    }

    int sCount = 0;
    int sDistance = 0;
    int sElevation = 0;
    int sTime = 0;

    final bool isEmpty = trailVM.nearTrailsExt.isEmpty || _trailExt == null;
    if (!isEmpty) {
      sCount = _trailExt!.user.statsLatest6Months.count;
      sDistance = _trailExt!.user.statsLatest6Months.distance;
      sElevation = _trailExt!.user.statsLatest6Months.elevation;
      sTime = _trailExt!.user.statsLatest6Months.time;
    }

    return AppSimpleScaffold(
      title: 'Nearby Your City',
      hideBack: true,
      physics: const NeverScrollableScrollPhysics(),
      actions: [
        AppWidgetButton(
          onTap: () {
            AppRoute.goTo('/profile_your_city');
          },
          child: Icon(
            Icons.home_outlined,
            color: appVM.yourCity == null ? AppTheme.clYellow : AppTheme.clText,
            size: 28,
          ),
        ),
        AppWidgetButton(
          onTap: _openFilters,
          child: Icon(
            Icons.tune_rounded,
            color: trailVM.trailFilters.isEmptyWithStranges
                ? AppTheme.clText
                : AppTheme.clYellow,
            size: 28,
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
      child: SizedBox(
        height: context.heightScaffold,
        width: context.width,
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: (_hidding0 || _hidding) ? 0.1 : 1.0,
              duration: 350.mlsec,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  0.hrr(height: 1),
                  5.h,
                  AppGestureButton(
                    onTap: () {
                      if (_trailExt == null) return;

                      AppRoute.goTo('/profile', args: {
                        'user': _trailExt!.user,
                      });
                    },
                    child: Container(
                      color: AppTheme.clBackground,
                      child: Column(
                        children: [
                          Container(
                            width: context.width,
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.appLR,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding:
                                        EdgeInsets.only(top: isEmpty ? 2 : 0),
                                    child: Text(
                                      isEmpty && !_loading && !_hidding0
                                          ? 'There is no one nearby.'
                                          : (isEmpty
                                              ? 'Searching...'
                                              : _trailExt!.user.fullName),
                                      style: TextStyle(
                                        fontSize: isEmpty ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: isEmpty
                                            ? AppTheme.clText03
                                            : AppTheme.clText,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        isEmpty
                                            ? ''
                                            : '@${_trailExt!.user.username}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.clText08,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          15.h,
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.appLR,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: context.width * 0.35,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Trails & Distance:',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.clText08,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  isEmpty
                                                      ? '0 / 0.0'
                                                      : '${'${fnNumCompact(sCount)} / '}${fnDistance(sDistance, compact: true)}',
                                                  style: TextStyle(
                                                    fontSize: 21,
                                                    fontWeight: FontWeight.bold,
                                                    color: isEmpty
                                                        ? AppTheme.clText03
                                                        : AppTheme.clText,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                isEmpty
                                                    ? 'D+ 0'
                                                    : 'D+ $sElevation',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: isEmpty
                                                      ? AppTheme.clText03
                                                      : AppTheme.clText,
                                                ),
                                                textAlign: TextAlign.end,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: context.width * 0.35,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Time:',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.clText08,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          isEmpty
                                              ? '0:00\'00'
                                              : fnTimeExt(sTime),
                                          style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold,
                                            color: isEmpty
                                                ? AppTheme.clText03
                                                : AppTheme.clText,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const Text(
                                        'Latest 6 months',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.clText04,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(right: 7),
                                  child: AppAvatarImage(
                                    size: 50,
                                    ageGroupStr:
                                        isEmpty ? '' : _ageGroupStr ?? '',
                                    pictureFile: isEmpty
                                        ? null
                                        : _trailExt!.user.cachePictureFile,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  5.h,
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          height: 2,
                          color: AppTheme.clBlack,
                        ),
                      ),
                      72.w,
                      Container(
                        width: 10,
                        alignment: Alignment.centerLeft,
                        height: 2,
                        color: AppTheme.clBlack,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 100,
                    width: context.width,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 82,
                          child: Container(
                            width: 2,
                            height: 100,
                            color: AppTheme.clBlack,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 8,
                          child: Container(
                            width: 2,
                            height: 100,
                            color: AppTheme.clBlack,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          child: Stack(
                            children: [
                              if (_page <= 3 || _rotate)
                                Positioned(
                                  left: AppTheme.appLR,
                                  top: 25,
                                  child: Image.asset(
                                    'assets/***/app_icon_tr.png',
                                    scale: 5,
                                    cacheHeight: 139,
                                    cacheWidth: 132,
                                    color: _rotate
                                        ? AppTheme.clYellow
                                        : AppTheme.clText05,
                                  ),
                                ),
                              PageView(
                                controller: _trlsCtrl,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  1.w,
                                  1.w,
                                  for (var trailsExt in trailVM.nearTrailsExt)
                                    Builder(
                                      builder: (context) {
                                        Color? color;
                                        if (_trailExt == trailsExt) {
                                          color = AppTheme.clYellow;
                                        }

                                        return Column(
                                          children: [
                                            AppGestureButton(
                                              onTap: () {
                                                AppRoute.goTo(
                                                  '/trail_card',
                                                  args: {
                                                    'trailExt': trailsExt,
                                                  },
                                                );
                                              },
                                              child: AppTCID(
                                                trail: trailsExt.trail,
                                                borderColor: color,
                                                labelColor: color,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          height: 2,
                          color: AppTheme.clBlack,
                        ),
                      ),
                      72.w,
                      Container(
                        width: 10,
                        alignment: Alignment.centerLeft,
                        height: 2,
                        color: AppTheme.clBlack,
                      )
                    ],
                  ),
                  Container(
                    color: AppTheme.clBackground,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        height: context.height * 0.48,
                        width: context.width,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            RadarDers(dist8th: _trailDist8th),
                            PageView.builder(
                              itemCount: trailVM.nearTrailsExt.length,
                              onPageChanged: (inx) {
                                setState(() {
                                  _page = inx;

                                  _setTrailExt(trailVM.nearTrailsExt
                                      .elementAtOrNull(inx));
                                });

                                _trlsCtrl.animateToPage(
                                  inx,
                                  duration: 250.mlsec,
                                  curve: Curves.linear,
                                );
                              },
                              physics: _hidding || _hidding0 || isEmpty
                                  ? const NeverScrollableScrollPhysics()
                                  : const AlwaysScrollableScrollPhysics(),
                              controller: _radarCtrl,
                              itemBuilder: (context, index) {
                                var scale = _page == index ? 1.0 : 0.8;

                                return TweenAnimationBuilder(
                                  duration: 750.mlsec,
                                  tween: Tween(begin: scale, end: scale),
                                  curve: Curves.ease,
                                  child: Container(
                                    padding: const EdgeInsets.all(25),
                                    child: RadarChartExt(
                                      dist8th: _trailDist8th,
                                      onShake: (double shakeDist) {
                                        setState(() {
                                          _reTrailDist8th(shakeDist);
                                        });
                                      },
                                      onDetails: () {
                                        if (_trailExt == null) return;

                                        AppRoute.goTo(
                                          '/trail_card',
                                          args: {
                                            'trailExt': _trailExt,
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: child,
                                    );
                                  },
                                );
                              },
                            ),
                            if (_trailExt == null)
                              Container(
                                color: AppTheme.clBackground,
                                child: Stack(
                                  children: [
                                    RadarDers(dist8th: _trailDist8th),
                                    PageView.builder(
                                      itemCount: 1,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      controller: _radarCtrl0,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          padding: const EdgeInsets.all(25),
                                          child: RadarChartExt(
                                            dist8th: _trailDist8th,
                                            onShake: (_) {},
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: AppTheme.appLR,
              top: 176,
              child: Opacity(
                opacity: _loading ? 1.0 : 0.0,
                child: AnimatedRotation(
                  duration: 500.mlsec,
                  turns: _rotate ? 0.5 : 0,
                  onEnd: () {
                    if (_loading) {
                      setState(() {
                        _rotate = !_rotate;
                      });
                    }
                  },
                  child: Image.asset(
                    'assets/***/app_icon_tr.png',
                    scale: 5,
                    cacheHeight: 139,
                    cacheWidth: 132,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RadarDers extends StatelessWidget {
  const RadarDers({
    super.key,
    required this.dist8th,
    this.lr = 10,
  });

  final List<List<dynamic>> dist8th;
  final double lr;

  @override
  Widget build(BuildContext context) {
    const TextStyle derecStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: AppTheme.clText03,
    );

    final List<List<String>> strDk = [];
    for (var der in cstRadarDers) {
      strDk.add([
        der,
        '${(dist8th[cstRadarDers.indexOf(der)].last).toStringAsFixed(0)} ${fnDistUnit()}',
      ]);
    }

    return Stack(
      children: [
        Positioned(
          left: lr,
          top: 0,
          child: Column(
            children: [
              Text(
                strDk[7].first,
                style: derecStyle,
              ),
              RotatedBox(
                quarterTurns: 1,
                child: Text(
                  ' ~  ${strDk[7].last}',
                  style: derecStyle,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: context.width / (lr == 10 ? 2.15 : 2.4),
          top: 0,
          child: Row(
            children: [
              Text(
                strDk[0].first,
                style: derecStyle,
              ),
              Text(
                '  ~  ${strDk[0].last}',
                style: derecStyle,
              ),
            ],
          ),
        ),
        Positioned(
          right: lr,
          top: 0,
          child: Column(
            children: [
              Text(
                strDk[1].first,
                style: derecStyle,
              ),
              RotatedBox(
                quarterTurns: 1,
                child: Text(
                  ' ~  ${strDk[1].last}',
                  style: derecStyle,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: lr - 2,
          top: 178,
          child: Column(
            children: [
              Text(
                '${strDk[2].first} ',
                style: derecStyle,
              ),
              RotatedBox(
                quarterTurns: 1,
                child: Text(
                  ' ~  ${strDk[2].last}',
                  style: derecStyle,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: lr,
          bottom: 0,
          child: Column(
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  ' ~  ${strDk[3].last}',
                  style: derecStyle,
                ),
              ),
              Text(
                strDk[3].first,
                style: derecStyle,
              ),
            ],
          ),
        ),
        Positioned(
          left: context.width / (lr == 10 ? 2.15 : 2.4),
          bottom: 0,
          child: Row(
            children: [
              Text(
                strDk[4].first,
                style: derecStyle,
              ),
              Text(
                '  ~  ${strDk[4].last}',
                style: derecStyle,
              ),
            ],
          ),
        ),
        Positioned(
          left: lr,
          bottom: 0,
          child: Column(
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  ' ~  ${strDk[5].last}',
                  style: derecStyle,
                ),
              ),
              Text(
                strDk[5].first,
                style: derecStyle,
              ),
            ],
          ),
        ),
        Positioned(
          left: lr - 2,
          top: 178,
          child: Column(
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  ' ~  ${strDk[6].last}',
                  style: derecStyle,
                ),
              ),
              Text(
                ' ${strDk[6].first}',
                style: derecStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
