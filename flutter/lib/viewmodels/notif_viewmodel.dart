// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:eraser/eraser.dart';

import 'package:trailcatch/constants.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/notif_model.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/pref_utils.dart';
import 'package:trailcatch/viewmodels/base_viewmodel.dart';

class NotifViewModel extends BaseViewModel {
  final List<NotifExtModel> _notifsExt = [];
  List<NotifExtModel> get notifsExt => _notifsExt;
  List<int> get notifIds =>
      _notifsExt.map((notifExt) => notifExt.notif.notifId).toList();

  bool _showFullNames = true;
  bool get showFullNames => _showFullNames;

  Future<void> reFetchNotifs({bool more = false}) async {
    if (!appVM.isUserExists) return;

    _showFullNames = (await fnPrefGetNotifsShowFullNames()) == 'Yes';

    DateTime createdFrom = DateTime.now();
    if (more && _notifsExt.isNotEmpty) {
      createdFrom = _notifsExt.last.notif.createdAt;
    }

    final List<NotifExtModel> notifsExt0 = await userServ.fnUsersNotifsFetch(
      createdFrom: createdFrom,
      limit: cstFirstLoadItemCount,
    );

    for (var notifExt0 in notifsExt0) {
      if (!notifIds.contains(notifExt0.notif.notifId)) {
        _notifsExt.add(notifExt0);
      }
    }

    if (notifsExt0.isNotEmpty) {
      _notifsExt.sort(
        (a, b) => b.notif.createdAt.compareTo(a.notif.createdAt),
      );
    }

    notify();
  }

  Future<void> markAsReadAllNotifs() async {
    await userServ.fnUsersNotifsMarkAllAsRead();
    await fnTry(Eraser.resetBadgeCountAndRemoveNotificationsFromCenter);

    appVM.settings.unreadNotifs = 0;
    appVM.notify();
  }
}
