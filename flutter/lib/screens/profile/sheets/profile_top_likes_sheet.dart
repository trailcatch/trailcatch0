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
import 'package:trailcatch/route.dart';
import 'package:trailcatch/screens/trails/widgets/trail_card.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/skeleton_utils.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class ProfileTopLikesSheet extends StatefulWidget {
  const ProfileTopLikesSheet({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  State<ProfileTopLikesSheet> createState() => _ProfileTopLikesSheetState();
}

class _ProfileTopLikesSheetState extends State<ProfileTopLikesSheet> {
  final ScrollController _ctrl = ScrollController();

  late bool _loadingSkeletons;
  late bool _loadingTop;
  late bool _loadingBottom;

  late List<TrailExtModel> _likeTopTrailsExt;

  @override
  void initState() {
    _loadingSkeletons = true;
    _loadingTop = false;
    _loadingBottom = false;

    _likeTopTrailsExt = [];

    scheduleMicrotask(_fetchTopLikes);

    super.initState();
  }

  Future<void> _fetchTopLikes({bool doClear = true}) async {
    if (!_loadingSkeletons && mounted && !_loadingBottom) {
      setState(() => _loadingTop = true);
    }

    await fnTry(() async {
      final List<TrailExtModel> likeTopTrailsExt0 =
          await trailServ.fnTrailsLikesTopFetch(
        userId: widget.user.userId,
        limit: cstFirstLoadItemCount,
        offset: doClear ? 0 : _likeTopTrailsExt.length,
      );

      if (doClear) {
        _likeTopTrailsExt = likeTopTrailsExt0;
      } else {
        final List<String> trailIds =
            _likeTopTrailsExt.map((trl) => trl.trail.trailId).toList();

        for (var likeTrailExt in likeTopTrailsExt0) {
          if (!trailIds.contains(likeTrailExt.trail.trailId)) {
            _likeTopTrailsExt.add(likeTrailExt);
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
    return AppBottomScaffold(
      title: 'Top Liked Trails',
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
          onRefresh: _fetchTopLikes,
          onLoadMore: () async {
            if (mounted) setState(() => _loadingBottom = true);

            await _fetchTopLikes(doClear: false);
          },
          children: [
            0.hrr(height: 1),
            if (_loadingSkeletons) ...[
              0.hrr(height: 10, color: AppTheme.clBackground),
              fnTrailSkeleton(context),
            ] else ...[
              if (_likeTopTrailsExt.isEmpty && !_loadingTop) ...[
                0.hrr(height: 10, color: AppTheme.clBackground),
                fnTrailSkeleton(context, true),
              ] else ...[
                0.hrr(height: 10, color: AppTheme.clBackground),
                for (var likeTrailExt in _likeTopTrailsExt) ...[
                  Column(
                    children: [
                      TrailCard(
                        trailExt: likeTrailExt,
                        onTap: () async {
                          await AppRoute.goTo('/trail_card', args: {
                            'trailExt': likeTrailExt,
                          });
                        },
                      ),
                      if (_likeTopTrailsExt.last != likeTrailExt)
                        0.hrr(height: 3),
                    ],
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}
