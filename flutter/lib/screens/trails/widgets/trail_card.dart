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
import 'package:trailcatch/screens/profile/widgets/profile_row_stat.dart';
import 'package:trailcatch/screens/radar/radar_screen.dart';
import 'package:trailcatch/screens/radar/widgets/radar_chart.dart';
import 'package:trailcatch/screens/trails/widgets/trail_card_chart.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/location_utils.dart';
import 'package:trailcatch/viewmodels/trail_viewmodel.dart';
import 'package:trailcatch/widgets/avatar_image.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/tcid.dart';

class TrailCard extends StatelessWidget {
  const TrailCard({
    super.key,
    required this.trailExt,
    this.onTap,
  });

  final TrailExtModel trailExt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    context.watch<TrailViewModel>();

    String dogNames = trailExt.dogsNames.join(', ');
    if (dogNames.isEmpty && trailExt.withDogs) {
      dogNames = 'Dog';
    }

    Color borderColor = AppTheme.clBackground;
    if (trailExt.trail.notPub && onTap != null) {
      borderColor = AppTheme.clYellow;
    }

    String? typeStr = TrailType.formatToStr(trailExt.trail.type);
    if (trailExt.withDogs && typeStr != null) {
      typeStr += ' & Dog';
      if (trailExt.dogsNames.length > 1) {
        typeStr += 's';
      }
    }

    return Container(
      alignment: Alignment.center,
      width: context.width,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.clBackground,
        border: Border.symmetric(
          vertical: BorderSide(width: 2, color: borderColor),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR - 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${trailExt.trail.datetimeAt.toDayOfWeek()}, ${trailExt.trail.datetimeAt.toTime()}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.clText08,
                    letterSpacing: 0.2,
                  ),
                ),
                10.w,
                Text(
                  trailExt.trail.datetimeAt.toDate(isY2: true, isD: true),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.clText08,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          5.hrr(height: 0.5, color: AppTheme.clText02, padLR: 15),
          5.h,
          Container(
            width: context.width,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppGestureButton(
                  onTap: () {
                    AppRoute.goTo('/profile', args: {
                      'user': trailExt.user,
                    });
                  },
                  child: AppAvatarImage(
                    size: 42,
                    pictureFile: trailExt.user.cachePictureFile,
                    utcp: trailExt.user.utcp,
                  ),
                ),
                10.w,
                Expanded(
                  child: AppGestureButton(
                    onTap: () {
                      AppRoute.goTo('/profile', args: {
                        'user': trailExt.user,
                      });
                    },
                    child: Container(
                      color: AppTheme.clBackground,
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          2.h,
                          if (trailExt.withDogs && dogNames.isNotEmpty) ...[
                            Text(
                              dogNames,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            2.h,
                            Text(
                              '& ${trailExt.user.fullName}',
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ] else ...[
                            Text(
                              trailExt.user.fullName,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            2.h,
                            Text(
                              '@${trailExt.user.username}',
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.clText05,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
                10.w,
                if (onTap != null)
                  AppGestureButton(
                    onTap: () {
                      AppRoute.showPopup(
                        [
                          AppPopupAction(
                            'Show Profile',
                            () async {
                              AppRoute.goTo('/profile', args: {
                                'user': trailExt.user,
                              });
                            },
                          ),
                          AppPopupAction(
                            'Show Trail Details',
                            () async => onTap?.call(),
                          ),
                          AppPopupAction(
                            'Share Trail',
                            () async {
                              appVM.shareTrail(trailExt.trail);
                            },
                          ),
                        ],
                      );
                    },
                    child: Container(
                      color: AppTheme.clBackground,
                      padding: const EdgeInsets.only(bottom: 15),
                      child: const Icon(
                        Icons.more_horiz_rounded,
                        color: AppTheme.clText,
                        size: 28,
                      ),
                    ),
                  )
                else
                  Opacity(
                    opacity: 0.8,
                    child: AppGestureButton(
                      onTap: () {
                        if (!trailExt.trail.notPub && !trailExt.trail.inTrash) {
                          appVM.shareTrail(trailExt.trail);
                        }
                      },
                      child: AppTCID(
                        height: 55,
                        trail: trailExt.trail,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          AppGestureButton(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.only(top: AppTheme.appDL),
              color: AppTheme.clBackground,
              child: ProfileRowStat(
                distance: trailExt.trail.distance,
                elevation: trailExt.trail.elevation,
                time: trailExt.trail.time,
                avgPace: trailExt.trail.avgPace,
                avgSpeed: trailExt.trail.avgSpeed,
                single: true,
                typeStr: typeStr,
                avgAnimate: onTap == null,
              ),
            ),
          ),
          7.h,
          if (onTap != null)
            AppGestureButton(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.only(top: 8),
                color: AppTheme.clBackground,
                child: TrailCardChart(trailExt: trailExt),
              ),
            )
          else
            TrailCardRadar(trailExt: trailExt),
          8.h,
          Opacity(
            opacity: trailExt.trail.notPub ? 0.3 : 1.0,
            child: Stack(
              children: [
                TrailCardLikesRow(trailExt: trailExt),
                if (trailExt.trail.notPub)
                  Container(
                    width: context.width,
                    height: 34,
                    color: AppTheme.clTransparent,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TrailCardRadar extends StatefulWidget {
  const TrailCardRadar({
    super.key,
    required this.trailExt,
  });

  final TrailExtModel trailExt;

  @override
  State<TrailCardRadar> createState() => _TrailCardRadarState();
}

class _TrailCardRadarState extends State<TrailCardRadar> {
  late double _shakeDist;

  @override
  void initState() {
    _shakeDist = cstDefRadarMaxDistance;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      List<List<dynamic>> trailDist8th = cstDist8thEmpty0;
      if (widget.trailExt.trail.deviceGeopoints != null) {
        trailDist8th = fnBuildTrailDist8th(
          widget.trailExt.trail.deviceGeopoints!,
          _shakeDist,
        );
      }

      return Container(
        width: context.width,
        height: 370,
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.appLR,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppTheme.clBlack02,
          border: Border.all(width: 1, color: AppTheme.clBlack),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Stack(
          children: [
            RadarDers(dist8th: trailDist8th, lr: 5),
            Container(
              padding: const EdgeInsets.all(25),
              child: RadarChartExt(
                dist8th: trailDist8th,
                onShake: (double shakeDist) {
                  setState(() {
                    _shakeDist = shakeDist;
                  });
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

class TrailCardLikesRow extends StatefulWidget {
  const TrailCardLikesRow({
    super.key,
    required this.trailExt,
  });

  final TrailExtModel trailExt;

  @override
  State<TrailCardLikesRow> createState() => _TrailCardLikesRowState();
}

class _TrailCardLikesRowState extends State<TrailCardLikesRow> {
  Future<void> _likeOrUnline() async {
    final likedByMe = widget.trailExt.likedByMe;

    setState(() {
      if (likedByMe) {
        widget.trailExt.likedByMe = false;
        widget.trailExt.likes -= 1;
        widget.trailExt.likesLatest4.remove(appVM.user.userId);

        fnShowToast('Unliked');
      } else {
        widget.trailExt.likedByMe = true;
        widget.trailExt.likes += 1;
        widget.trailExt.likesLatest4.insert(0, appVM.user.userId);

        fnShowToast('Liked');
      }
    });

    fnHaptic();

    trailServ.fnTrailsLike(
      userId: widget.trailExt.trail.userId,
      trailId: widget.trailExt.trail.trailId,
      like: widget.trailExt.likedByMe,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isSubscribed = widget.trailExt.user.rlship == 1;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.appLR,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppGestureButton(
            onTry: _likeOrUnline,
            child: Container(
              color: AppTheme.clBackground,
              padding: const EdgeInsets.only(top: 4, right: 4, left: 4),
              child: Icon(
                widget.trailExt.likedByMe
                    ? Icons.favorite
                    : Icons.favorite_border_outlined,
                size: 22,
                color: widget.trailExt.likedByMe
                    ? AppTheme.clYellow08
                    : AppTheme.clText,
              ),
            ),
          ),
          10.w,
          Container(
            padding: const EdgeInsets.only(top: 5),
            child: const Text(
              '|',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.clText07,
              ),
            ),
          ),
          15.w,
          GestureDetector(
            onTap: () {
              if (widget.trailExt.likes > 0) {
                AppRoute.goSheetTo('/trail_likes', args: {
                  'trail': widget.trailExt.trail,
                });
              }
            },
            child: Container(
              color: AppTheme.clBackground,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              margin: const EdgeInsets.only(top: 4),
              child: Builder(builder: (context) {
                final likesCount = fnNumCompact(widget.trailExt.likes);
                final String likes4thStr =
                    '$likesCount like${widget.trailExt.likes > 1 ? 's' : ''}';

                double width = 66;
                if (widget.trailExt.likesLatest4.length == 1) {
                  width = 30;
                } else if (widget.trailExt.likesLatest4.length == 2) {
                  width = 42;
                } else if (widget.trailExt.likesLatest4.length == 3) {
                  width = 54;
                }

                final likesLatest4 =
                    widget.trailExt.likesLatest4.take(4).toList();

                return Row(
                  children: [
                    if (widget.trailExt.likes != 0) ...[
                      SizedBox(
                        height: 22,
                        width: width,
                        child: Stack(
                          children: [
                            for (var inx
                                in List.generate(likesLatest4.length, (i) => i))
                              Positioned(
                                left: 12.0 * inx,
                                top: 0,
                                child: AppAvatarImage(
                                  size: 22,
                                  pictureFile: storageServ.uuidToFile(
                                    uuid: likesLatest4[inx],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          likes4thStr,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      )
                    ] else ...[
                      const AppAvatarImage(size: 22),
                      8.w,
                      Container(
                        padding: const EdgeInsets.only(top: 1),
                        child: const Text(
                          'No likes yet',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              10.w,
              AppGestureButton(
                onTry: () async {
                  if (widget.trailExt.isMy) return;

                  if (!isSubscribed) {
                    fnHaptic();

                    appVM.subscribeUser(widget.trailExt.user);
                    appVM.notify();
                    trailVM.notify();

                    fnShowToast('Subscribed');
                  } else {
                    AppRoute.showPopup(
                      [
                        AppPopupAction(
                          'Unsubscribe',
                          color: AppTheme.clRed,
                          () async {
                            fnHaptic();

                            await appVM.removeRlshipUser(widget.trailExt.user);
                            appVM.notify();
                            trailVM.notify();

                            fnShowToast('Unsubscribed');
                          },
                        ),
                      ],
                    );
                  }
                },
                child: Container(
                  color: AppTheme.clBackground,
                  padding: const EdgeInsets.only(top: 4, right: 4, left: 4),
                  child: Icon(
                    isSubscribed
                        ? Icons.person_add_alt_1
                        : Icons.person_add_alt_1_outlined,
                    size: 22,
                    color: widget.trailExt.isMy
                        ? AppTheme.clText02
                        : (isSubscribed ? AppTheme.clYellow : AppTheme.clText),
                  ),
                ),
              ),
              10.w,
              Container(
                padding: const EdgeInsets.only(top: 3),
                child: const Text(
                  '|',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.clText07,
                  ),
                ),
              ),
              10.w,
              AppGestureButton(
                onTry: () async {
                  if (!widget.trailExt.trail.notPub &&
                      !widget.trailExt.trail.inTrash) {
                    appVM.shareTrail(widget.trailExt.trail);
                  }
                },
                child: Container(
                  color: AppTheme.clBackground,
                  padding: const EdgeInsets.only(top: 0, right: 4, left: 4),
                  child: const Icon(
                    Icons.ios_share_rounded,
                    size: 22,
                    color: AppTheme.clText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
