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

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/notif_model.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/pref_utils.dart';
import 'package:trailcatch/utils/skeleton_utils.dart';
import 'package:trailcatch/viewmodels/notif_viewmodel.dart';
import 'package:trailcatch/widgets/avatar_image.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/buttons/widget_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';
import 'package:trailcatch/widgets/tcid.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _ctrl = ScrollController();

  late bool _loadingSkeletons;
  late bool _loadingTop;
  late bool _loadingBottom;
  late bool _noMoreNotifs;

  late bool _showFullNames;

  @override
  void initState() {
    _loadingSkeletons = notifVM.notifsExt.isEmpty;
    _loadingTop = false;
    _loadingBottom = false;
    _noMoreNotifs = false;

    _showFullNames = notifVM.showFullNames;

    scheduleMicrotask(() async {
      await _fetchNotifs();

      notifVM.markAsReadAllNotifs();
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    context.watch<NotifViewModel>();

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _ctrl.dispose();

    super.dispose();
  }

  Future<void> _fetchNotifs() async {
    if (_loadingBottom) return;

    if (!_loadingSkeletons && mounted) {
      setState(() {
        _loadingTop = true;
      });
    }

    _noMoreNotifs = false;
    await notifVM.reFetchNotifs();

    if (mounted) {
      setState(() {
        _loadingTop = false;
        _loadingSkeletons = false;
      });
    }
  }

  Future<void> _fetchMoreTrails() async {
    if (_loadingTop || _loadingSkeletons) return;
    if (notifVM.notifsExt.isEmpty) return;

    setState(() {
      _loadingBottom = true;
    });

    final int trailsCountBefore = notifVM.notifIds.length;

    await notifVM.reFetchNotifs(more: true);

    final int trailsCountAfter = notifVM.notifIds.length;

    setState(() {
      _loadingBottom = false;

      if (trailsCountBefore == trailsCountAfter) {
        _noMoreNotifs = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gNotifsExt = groupBy(notifVM.notifsExt, (notifExt) {
      return notifExt.notif.createdAt.toIso8601String().substring(0, 10);
    }).map((key, value) {
      value.sort((a, b) => b.notif.createdAt.compareTo(a.notif.createdAt));

      return MapEntry(key, value);
    });

    return AppSimpleScaffold(
      title: 'Notifications',
      loadingTop: _loadingTop,
      loadingBottom: _loadingBottom,
      scrollCtrl: _ctrl,
      physics: const AlwaysScrollableScrollPhysics(),
      onRefresh: _fetchNotifs,
      onLoadMore: _noMoreNotifs ? null : _fetchMoreTrails,
      loadMoreAnimate: true,
      actions: [
        AppWidgetButton(
          onTap: () {
            if (notifVM.notifsExt.isEmpty) return;

            setState(() {
              _showFullNames = !_showFullNames;
            });

            fnPrefSaveNotifsShowFullNames(_showFullNames ? 'Yes' : 'No');

            fnShowToast(
              'Show ${_showFullNames ? 'full names' : 'usernames'}',
            );
          },
          child: Icon(
            Icons.text_fields,
            color: _showFullNames
                ? AppTheme.clYellow
                : (notifVM.notifsExt.isEmpty
                    ? AppTheme.clText03
                    : AppTheme.clText),
            size: 26,
          ),
        ),
      ],
      children: [
        if (_loadingSkeletons) ...[
          fnNotifSkeleton(context),
          5.h,
          fnNotifSkeleton(context),
          10.h,
        ] else ...[
          if (notifVM.notifsExt.isEmpty) ...[
            fnNotifSkeleton(context, true),
            5.h,
            fnNotifSkeleton(context, true),
            10.h,
          ] else
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                for (var gNotif in gNotifsExt.entries)
                  Builder(builder: (context) {
                    final dt = DateTime.parse(gNotif.key);
                    String title = fnDateFormat("LLLL d, ''yy", dt).toTitle();

                    if (DateUtils.isSameDay(DateTime.now(), dt)) {
                      title = 'Today';
                    } else if (DateUtils.isSameDay(
                      DateTime.now().subtract(const Duration(days: 1)),
                      dt,
                    )) {
                      title = 'Yesterday';
                    }

                    List<NotifExtModel> notifsExt = gNotif.value;

                    final trl = gNotif.value.firstWhereOrNull((vl) {
                      return vl.trail != null;
                    });

                    Map<String?, List<NotifExtModel>> gtd = {};
                    if (trl != null) {
                      gtd = groupBy(notifsExt.where((ntf) {
                        return ntf.trail != null;
                      }), (notifExt) {
                        return notifExt.notif.trail1Id;
                      }).map((key, value) {
                        value.sort((a, b) =>
                            a.notif.createdAt.compareTo(b.notif.createdAt));

                        return MapEntry(key, value);
                      });
                    }

                    return Container(
                      color: AppTheme.clBackground,
                      child: Column(
                        children: [
                          Container(
                            color: AppTheme.clBlack,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.appLR,
                              vertical: 7,
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.clText,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                          10.h,
                          Container(
                            width: context.width,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.appLR - 4,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    SizedBox(
                                      width: context.width,
                                      child: NotifColumn(
                                        showLikes: false,
                                        notifsExt: notifsExt,
                                        showFullNames: _showFullNames,
                                        isHr: gtd.values.isNotEmpty,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: context.width,
                                  child: Column(
                                    children: [
                                      if (gtd.values.isNotEmpty)
                                        for (var gtdit in gtd.entries) ...[
                                          NotifColumn(
                                            showLikes: true,
                                            notifsExt: gtdit.value,
                                            showFullNames: _showFullNames,
                                            isHr: gtd.keys.last != gtdit.key,
                                          ),
                                        ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          20.h,
                        ],
                      ),
                    );
                  }),
              ],
            )
        ],
      ],
    );
  }
}

class NotifColumn extends StatefulWidget {
  const NotifColumn({
    super.key,
    required this.showLikes,
    required this.notifsExt,
    required this.showFullNames,
    required this.isHr,
  });

  final bool showLikes;
  final List<NotifExtModel> notifsExt;
  final bool showFullNames;
  final bool isHr;

  @override
  State<NotifColumn> createState() => _NotifColumnState();
}

class _NotifColumnState extends State<NotifColumn> {
  bool _isRead = false;

  @override
  void initState() {
    _isRead = widget.notifsExt.first.notif.read;

    if (!_isRead) {
      scheduleMicrotask(() {
        Future.delayed(1000.mlsec, () {
          setState(() {
            _isRead = true;

            for (var ntf in widget.notifsExt) {
              ntf.notif.read = true;
            }
          });
        });
      });
    }

    super.initState();
  }

  void _notifsUsers(List<NotifExtModel> notifs) {
    if (notifs.isNotEmpty) {
      AppRoute.goSheetTo('/notifs_users', args: {
        'notifsExt': notifs,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<NotifExtModel> notifs = widget.notifsExt.where((notif) {
      if (widget.showLikes) {
        return notif.trail != null;
      } else {
        return notif.trail == null;
      }
    }).toList();

    if (notifs.isEmpty) {
      return Container();
    }

    final TrailModel? trail = notifs.first.trail;
    final int otherCount = notifs.length - 10;

    List<String> usersIds6th = notifs
        .take(6)
        .map((notifExt) => notifExt.user2?.userId)
        .whereType<String>()
        .toList();

    if (usersIds6th.length < 6) {
      for (var sklt in List.generate(6 - usersIds6th.length, (i) => '0')) {
        usersIds6th.add(sklt);
      }
    }

    if (usersIds6th.length == 6) {
      usersIds6th.last = '-1';
    }

    usersIds6th = usersIds6th.reversed.toList();

    final List<String> names10th = notifs
        .take(10)
        .map((notifExt) {
          return widget.showFullNames
              ? notifExt.user2?.fullName
              : notifExt.user2?.username;
        })
        .whereType<String>()
        .toList();

    List<DateTime> dates4th = [];
    if (notifs.length < 4) {
      dates4th.addAll(
        [
          for (var notifExt in notifs) notifExt.notif.createdAt,
        ],
      );
    } else if (notifs.length >= 4) {
      dates4th.addAll(
        [
          notifs[0].notif.createdAt,
          notifs[1].notif.createdAt,
          notifs[notifs.length - 2].notif.createdAt,
          notifs[notifs.length - 1].notif.createdAt,
        ],
      );
    }

    final BorderSide bleft = BorderSide(
      width: 2,
      color: _isRead ? AppTheme.clBackground : AppTheme.clYellow,
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: AnimatedContainer(
            duration: 500.mlsec,
            width: context.width,
            decoration: BoxDecoration(
              border: Border(left: bleft),
            ),
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            alignment: widget.showLikes
                                ? Alignment.centerLeft
                                : Alignment.center,
                            child: AppGestureButton(
                              onTap: () => _notifsUsers(notifs),
                              child: SizedBox(
                                height: 30,
                                width: 154,
                                child: Stack(
                                  children: [
                                    for (var inx in List.generate(
                                      usersIds6th.length,
                                      (i) => i,
                                    ))
                                      Positioned(
                                        right: 24.0 * inx +
                                            (usersIds6th[inx] == '-1' ? 6 : 0),
                                        top: 0,
                                        child: usersIds6th[inx] == '0'
                                            ? Container(
                                                height: 30,
                                                width: 30,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(6),
                                                  ),
                                                  color: AppTheme.clBlack02,
                                                  border: Border.all(
                                                    width: 1,
                                                    color: AppTheme.clBlack,
                                                  ),
                                                ),
                                              )
                                            : (usersIds6th[inx] == '-1'
                                                ? Container(
                                                    height: 30,
                                                    width: 22,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                        Radius.circular(6),
                                                      ),
                                                      color: AppTheme.clBlack,
                                                      border: Border.all(
                                                        width: 1,
                                                        color: AppTheme.clBlack,
                                                      ),
                                                    ),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      padding: EdgeInsets.only(
                                                          right:
                                                              usersIds6th[1] ==
                                                                      '0'
                                                                  ? 4
                                                                  : 2),
                                                      child: const Icon(
                                                        Icons.unfold_more,
                                                        size: 11,
                                                        color:
                                                            AppTheme.clText05,
                                                      ),
                                                    ),
                                                  )
                                                : AppAvatarImage(
                                                    size: 30,
                                                    pictureFile:
                                                        storageServ.uuidToFile(
                                                      uuid: usersIds6th[inx],
                                                    ),
                                                  )),
                                      )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (trail != null && widget.showLikes)
                          AppGestureButton(
                            onTap: () {},
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 10),
                              child: AppTCID(
                                trail: trail,
                                height: 70,
                              ),
                            ),
                          )
                      ],
                    ),
                    if (!widget.showLikes) 15.h,
                    Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (var date4th in dates4th) ...[
                            Text(
                              date4th.toTime(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.clText07,
                              ),
                            ),
                            if (dates4th.last != date4th)
                              if (dates4th.indexOf(date4th) == 1 &&
                                  notifs.length >= 4)
                                const Text(
                                  '...',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.clText07,
                                  ),
                                )
                              else
                                const Text(
                                  '-',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.clText07,
                                  ),
                                ),
                          ],
                        ],
                      ),
                    ),
                    15.h,
                    AppGestureButton(
                      onTap: () => _notifsUsers(notifs),
                      child: RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          text: widget.showLikes ? 'Liked by' : 'Subscribed by',
                          style: const TextStyle(
                            fontSize: 14,
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            for (var name in names10th) ...[
                              TextSpan(
                                text:
                                    '${names10th.last == name && otherCount <= 0 && names10th.length != 1 ? ' and' : (names10th.first == name ? '' : ',')} ',
                                style: const TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 0.2,
                                  height: 1.4,
                                  color: AppTheme.clText,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              TextSpan(
                                text: name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 0.2,
                                  height: 1.4,
                                  color: AppTheme.clText,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                            if (otherCount > 0)
                              TextSpan(
                                text:
                                    ' and $otherCount other${otherCount > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 0.2,
                                  height: 1.4,
                                  color: AppTheme.clText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (widget.isHr)
          8.hrr(
            height: 2,
            color: AppTheme.clBlack,
            padLR: 20,
          ),
      ],
    );
  }
}
