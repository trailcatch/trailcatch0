// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/screens/trails/widgets/trail_card.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/skeleton_utils.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class ProfileMonthTrailsSheet extends StatefulWidget {
  const ProfileMonthTrailsSheet({
    super.key,
    required this.user,
    required this.monthAt,
  });

  final UserModel user;
  final DateTime monthAt;

  @override
  State<ProfileMonthTrailsSheet> createState() =>
      _ProfileMonthTrailsSheetState();
}

class _ProfileMonthTrailsSheetState extends State<ProfileMonthTrailsSheet> {
  late bool _loadingSkeletons;
  late List<TrailExtModel> _trailsExt;

  @override
  void initState() {
    _loadingSkeletons = true;

    _trailsExt = [];

    scheduleMicrotask(
      () => _fetchTrails(),
    );

    super.initState();
  }

  Future<void> _fetchTrails() async {
    if (!_loadingSkeletons && mounted) {
      setState(() {
        _loadingSkeletons = true;
      });
    }

    final to = DateTime(
      widget.monthAt.year,
      widget.monthAt.month,
      1,
    );

    final from = DateTime(
      widget.monthAt.year,
      widget.monthAt.month + 1,
      1,
      0,
      0,
    );

    await fnTry(() async {
      _trailsExt = await trailServ.fnTrailsFetch(
        userId: widget.user.userId,
        inTrashNotPub: false,
        syncDate: SyncDate(
          from: from,
          to: to,
          limit: 1000,
        ),
      );
    }, delay: 250.mlsec);

    if (mounted) {
      setState(() {
        _loadingSkeletons = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomScaffold(
      title: widget.monthAt.toMonthYear(isY2: true),
      padTop: 0,
      padBottom: 0,
      child: SizedBox(
        height: context.height * 0.75,
        width: context.width,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        if (_trailsExt.last != trailExt) 0.hrr(height: 5),
                      ],
                    ),
                (context.notch + 10).h,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
