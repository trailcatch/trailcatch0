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
import 'package:trailcatch/screens/profile/widgets/profile_rlship.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/skeleton_utils.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class TrailLikesSheet extends StatefulWidget {
  const TrailLikesSheet({
    super.key,
    required this.trail,
  });

  final TrailModel trail;

  @override
  State<TrailLikesSheet> createState() => _TrailLikesSheetState();
}

class _TrailLikesSheetState extends State<TrailLikesSheet> {
  final ScrollController _ctrl = ScrollController();

  late bool _loadingSkeletons;
  late bool _loadingTop;
  late bool _loadingBottom;

  late List<TrailExtModel> _likeTrailsExt;

  @override
  void initState() {
    _loadingSkeletons = true;
    _loadingTop = false;
    _loadingBottom = false;

    _likeTrailsExt = [];

    scheduleMicrotask(_fetchLikes);

    super.initState();
  }

  Future<void> _fetchLikes({bool doClear = true}) async {
    if (!_loadingSkeletons && mounted && !_loadingBottom) {
      setState(() => _loadingTop = true);
    }

    await fnTry(() async {
      if (doClear) {
        _likeTrailsExt.clear();
      }

      final List<TrailExtModel> likeTrailsExt0 =
          await trailServ.fnTrailsLikesFetch(
        trailId: widget.trail.trailId,
        likeCreatedAt: _likeTrailsExt.lastOrNull?.likeCreatedAt,
        limit: cstFirstLoadItemCount,
      );

      final List<String> userIds =
          _likeTrailsExt.map((trl) => trl.user.userId).toList();

      for (var likeTrailExt in likeTrailsExt0) {
        if (!userIds.contains(likeTrailExt.user.userId)) {
          _likeTrailsExt.add(likeTrailExt);
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
    return AppBottomScaffold(
      title: 'Likes',
      padTop: 0,
      padBottom: 0,
      heightTop: 0,
      child: SizedBox(
        height: context.height * 0.815,
        width: context.width,
        child: AppSimpleScaffold(
          loadingTop: _loadingTop,
          loadingBottom: _loadingBottom,
          scrollCtrl: _ctrl,
          physics: const AlwaysScrollableScrollPhysics(),
          onRefresh: _fetchLikes,
          onLoadMore: () async {
            if (mounted) setState(() => _loadingBottom = true);

            await _fetchLikes(doClear: false);
          },
          children: [
            0.hrr(height: 1),
            if (_loadingSkeletons) ...[
              0.hrr(height: 10, color: AppTheme.clBackground),
              fnUserSkeleton(context),
            ] else ...[
              if (_likeTrailsExt.isEmpty) ...[
                0.hrr(height: 10, color: AppTheme.clBackground),
                fnUserSkeleton(context, true),
              ] else ...[
                0.hrr(height: 10, color: AppTheme.clBackground),
                for (var likeTrailExt in _likeTrailsExt) ...[
                  ProfileRlship(trailExt: likeTrailExt),
                  0.hrr(height: 10, color: AppTheme.clBackground),
                  0.hrr(height: 1.5, color: AppTheme.clBlack),
                  if (_likeTrailsExt.last != likeTrailExt)
                    0.hrr(height: 10, color: AppTheme.clBackground),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}
