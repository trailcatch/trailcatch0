// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/models/notif_model.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/screens/profile/widgets/profile_rlship.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class NotifsUsersSheet extends StatefulWidget {
  const NotifsUsersSheet({
    super.key,
    this.notifsExt,
  });

  final List<NotifExtModel>? notifsExt;

  @override
  State<NotifsUsersSheet> createState() => _NotifsUsersSheetState();
}

class _NotifsUsersSheetState extends State<NotifsUsersSheet> {
  late List<NotifExtModel> _notifsExt;

  @override
  void initState() {
    _notifsExt = widget.notifsExt ?? [];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final trl = _notifsExt.first.trail;

    return AppBottomScaffold(
      title: trl != null ? 'Liked by' : 'Subscribed by',
      padTop: 0,
      padBottom: 0,
      heightTop: 0,
      child: SizedBox(
        height: context.height * 0.815,
        width: context.width,
        child: AppSimpleScaffold(
          physics: const ClampingScrollPhysics(),
          children: [
            0.hrr(height: 10, color: AppTheme.clBackground),
            for (var notifExt in _notifsExt) ...[
              ProfileRlship(
                trailId: notifExt.latestTrail2!.trailId,
                trailExt: TrailExtModel(
                  trail: notifExt.latestTrail2!,
                  user: notifExt.user2!,
                  likes: 0,
                  likedByMe: false,
                  likesLatest4: [],
                ),
              ),
              0.hrr(height: 10, color: AppTheme.clBackground),
              0.hrr(height: 1.5, color: AppTheme.clBlack),
              if (_notifsExt.last != notifExt)
                0.hrr(height: 10, color: AppTheme.clBackground),
            ],
          ],
        ),
      ),
    );
  }
}
