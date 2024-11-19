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

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/device_model.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/screens/trails/widgets/trail_card_details.dart';
import 'package:trailcatch/screens/trails/widgets/trail_card.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/viewmodels/trail_viewmodel.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/buttons/widget_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class TrailCardScreen extends StatefulWidget {
  const TrailCardScreen({
    super.key,
    this.trailExt,
    this.trailId,
  });

  final TrailExtModel? trailExt;
  final String? trailId;

  @override
  State<TrailCardScreen> createState() => _TrailCardScreenState();
}

class _TrailCardScreenState extends State<TrailCardScreen> {
  final ScrollController _ctrl = ScrollController();

  late bool _loadingTrail;
  late TrailExtModel _trailExt;

  late bool _loading;
  late bool _loadingT;
  late bool _isEditMode;
  late bool _isRefresh;

  @override
  void initState() {
    _loading = false;
    _loadingT = false;
    _isEditMode = false;
    _isRefresh = false;

    _loadingTrail = false;

    if (widget.trailExt != null) {
      _trailExt = widget.trailExt!;
    } else if (widget.trailId != null) {
      _loadingTrail = true;

      trailServ.fnTrailsFetch(trailId: widget.trailId!).then(
        (List<TrailExtModel> trailsExt) async {
          if (trailsExt.isNotEmpty) {
            scheduleMicrotask(() {
              setState(() {
                _loadingTrail = false;
                _trailExt = trailsExt.single;
              });
            });
          } else {
            _trailNotFound();
          }
        },
      );
    } else {
      _loadingTrail = true;
      _trailNotFound();
    }

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

  void _trailNotFound() {
    Future.delayed(250.mlsec, () {
      AppRoute.goBack();

      throw AppError(
        message: 'Trail not found.',
        code: AppErrorCode.trailNotFound,
      );
    });
  }

  Future<void> _doTrailUpdate() async {
    setState(() {
      _loadingT = true;
    });

    await trailVM.updateTrail(
      trail: _trailExt.trail,
    );

    trailVM.notify();

    setState(() {
      _loadingT = false;
      _isRefresh = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingTrail) {
      return AppSimpleScaffold(
        title: 'Trail Card',
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

    Widget wBottom = Column(
      children: [
        0.hrr(height: 2),
        10.h,
        if (_trailExt.trail.notPub)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppSimpleButton(
                width: context.width * AppTheme.appBtnWidth,
                text: 'Publish Trail',
                textColor: AppTheme.clYellow,
                borderColor: AppTheme.clYellow,
                onTry: () async {
                  if (fnIsDemo(silence: false)) return;

                  if (!(await trailVM.isAllowToPublish())) {
                    AppRoute.goSheetTo('/trail_not_allow_pub');
                    return;
                  }

                  setState(() {
                    _loading = true;
                  });

                  _trailExt.trail.notPub = false;
                  _trailExt.trail.inTrash = false;
                  _trailExt.trail.pubAt ??= DateTime.now();

                  await fnTry(() async {
                    await trailVM.updateTrail(
                      trail: _trailExt.trail,
                    );
                  }, delay: 1000.mlsec);

                  trailVM.notify();

                  setState(() {
                    _isEditMode = false;
                    _loading = false;
                    _isRefresh = true;
                  });
                },
              ),
            ],
          )
        else if (_trailExt.trail.inTrash)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppSimpleButton(
                width: context.width * AppTheme.appBtnWidth,
                text: 'Restore from Trash',
                onTry: () async {
                  await trailVM.trashBackTrail(_trailExt);
                },
              ),
            ],
          ),
      ],
    );

    String title = 'Trail Card';
    if (_trailExt.trail.notPub) {
      title = 'Publish Trail';
    } else if (_trailExt.trail.inTrash) {
      title = 'In Trash Trail';
    }

    return AppSimpleScaffold(
      title: title,
      loading: _loading,
      loadingT: _loadingT,
      onBack: () async {
        if (_loading) return;

        AppRoute.goBack(_isRefresh);
      },
      scrollCtrl: _ctrl,
      actions: [
        if (_trailExt.isMy && appVM.user.withDogs)
          AppWidgetButton(
            onTap: () async {
              if (_isEditMode) return;

              final isTrailUpdated = await AppRoute.goSheetTo(
                '/trail_with_dogs',
                args: {
                  'trailExt': _trailExt,
                },
              );

              trailVM.notify();

              if (isTrailUpdated ?? false) {
                _doTrailUpdate();
              }
            },
            child: Icon(
              Icons.pets,
              color: _isEditMode
                  ? (_trailExt.withDogs
                      ? AppTheme.clYellow01
                      : AppTheme.clText01)
                  : (_trailExt.withDogs ? AppTheme.clYellow : AppTheme.clText),
              size: 25,
            ),
          ),
        if (_trailExt.isMy)
          AppWidgetButton(
            onTap: () async {
              setState(() {
                _isEditMode = !_isEditMode;
              });

              if (_ctrl.position.pixels <= 100 && _isEditMode) {
                Future.delayed(250.mlsec, () {
                  _ctrl.animateTo(
                    350,
                    duration: 250.mlsec,
                    curve: Curves.linear,
                  );
                });
              }
            },
            child: Icon(
              Icons.settings_outlined,
              color: _isEditMode ? AppTheme.clYellow : AppTheme.clText,
              size: 25,
            ),
          ),
        if (!_trailExt.trail.notPub && !_trailExt.trail.inTrash)
          AppWidgetButton(
            onTap: () {
              if (_isEditMode) return;

              AppRoute.showPopup(
                [
                  AppPopupAction(
                    'Show Profile',
                    () async {
                      AppRoute.goTo('/profile', args: {
                        'user': _trailExt.user,
                      });
                    },
                  ),
                  AppPopupAction(
                    'Share Trail',
                    () async {
                      appVM.shareTrail(_trailExt.trail);
                    },
                  ),
                  if (_trailExt.isMy)
                    AppPopupAction(
                      'Move Trail to Trash',
                      color: AppTheme.clRed,
                      () async {
                        AppRoute.showPopup(
                          title:
                              'You\'re about to move the trail to the trash.\nYou\'ll be able to publish it again later.',
                          [
                            AppPopupAction(
                              'Move Trail to Trash',
                              color: AppTheme.clRed,
                              () async {
                                await trailVM.trashTrails([_trailExt]);
                                AppRoute.goBack(true);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                ],
              );
            },
            child: Icon(
              Icons.hdr_weak,
              color: _isEditMode ? AppTheme.clText01 : AppTheme.clText,
              size: 27,
            ),
          )
        else if (_trailExt.trail.notPub)
          AppWidgetButton(
            onTap: () async {
              if (_isEditMode) return;

              AppRoute.showPopup(
                title:
                    'You\'re about to move the trail to the trash.\nYou\'ll be able to publish it again later.',
                [
                  AppPopupAction(
                    'Move Trail to Trash',
                    color: AppTheme.clRed,
                    () async {
                      await trailVM.trashTrails([_trailExt]);
                      AppRoute.goBack(true);
                    },
                  ),
                ],
              );
            },
            child: Container(
              padding: const EdgeInsets.only(bottom: 2, right: 2),
              child: Icon(
                Icons.delete_outline_rounded,
                color: _isEditMode ? AppTheme.clRed03 : AppTheme.clRed,
                size: 27,
              ),
            ),
          )
        else if (_trailExt.trail.inTrash)
          AppWidgetButton(
            onTap: () async {
              if (_isEditMode) return;

              AppRoute.showPopup(
                [
                  AppPopupAction(
                    'Delete Trail Permanently',
                    color: AppTheme.clRed,
                    () async {
                      if (fnIsDemo(silence: false)) return;

                      AppRoute.showPopup(
                        title:
                            'You\'re about to delete trail permanently. \nYou\'ll always be able to publish it again later.',
                        [
                          AppPopupAction(
                            'Delete Trail Permanently',
                            color: AppTheme.clRed,
                            () async {
                              await trailVM.deleteTrail(_trailExt);
                              AppRoute.goBack(true);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
            child: Container(
              padding: const EdgeInsets.only(bottom: 2, right: 2),
              child: Icon(
                Icons.delete_forever_outlined,
                color: _isEditMode ? AppTheme.clRed03 : AppTheme.clRed,
                size: 27,
              ),
            ),
          ),
      ],
      wBottom:
          _trailExt.trail.notPub || _trailExt.trail.inTrash ? wBottom : null,
      children: [
        TrailCard(trailExt: _trailExt),
        10.h,
        Builder(builder: (context) {
          return TrailCardDetails(
            trailExt: _trailExt,
            isEditMode: _isEditMode,
            onChanged: () {
              _doTrailUpdate();
            },
          );
        })
      ],
    );
  }
}
