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
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/skeleton_utils.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';
import 'package:trailcatch/widgets/textfield.dart';

class RadarSearchSheet extends StatefulWidget {
  const RadarSearchSheet({
    super.key,
  });

  @override
  State<RadarSearchSheet> createState() => _RadarSearchSheetState();
}

class _RadarSearchSheetState extends State<RadarSearchSheet> {
  late final TextEditingController _searchCtrl;
  final ScrollController _ctrl = ScrollController();

  final _debouncer = AppDebouncer(delay: const Duration(milliseconds: 500));

  late bool _loadingSkeletons;
  late bool _loadingBottom;
  late bool _loadingTop;

  List<TrailExtModel> _trailsExt = [];
  String? _searchQ;

  @override
  void initState() {
    _searchCtrl = TextEditingController();

    _loadingSkeletons = false;
    _loadingBottom = false;
    _loadingTop = false;

    _trailsExt = [];

    super.initState();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _searchCtrl.dispose();
    _debouncer.cancel();

    super.dispose();
  }

  Future<void> _fetchPeople({int? offset}) async {
    await fnTry(() async {
      final trailsExt0 = await trailServ.fnTrailsFetchPeople(
        syncDate: SyncDate(
          offset: offset ?? _trailsExt.length,
          limit: cstFirstLoadNearItemCount,
        ),
        searchQ: _searchQ,
      );

      final userIds = _trailsExt.map((trl) => trl.user.userId).toSet();
      for (var trl in trailsExt0) {
        if (!userIds.contains(trl.user.userId)) {
          _trailsExt.add(trl);
        }
      }
    }, delay: (_loadingSkeletons ? 1000 : 0).mlsec);

    if (mounted) {
      setState(() {
        _loadingBottom = false;
        _loadingSkeletons = false;
        _loadingTop = false;
      });
    }
  }

  void _onClear() {
    setState(() {
      _searchCtrl.text = '';
      _searchQ = null;
      _trailsExt.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<TrailExtModel> trailsExt = _trailsExt;
    if (_searchCtrl.text.isEmpty && _trailsExt.isEmpty) {
      trailsExt = trailVM.nearTrailsExt;
    }

    return AppBottomScaffold(
      title: 'Search People',
      padTop: 0,
      padBottom: 0,
      heightTop: 0,
      child: SizedBox(
        height: context.height * 0.815,
        width: context.width,
        child: Column(
          children: [
            5.h,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
              child: AppTextField(
                placeholder: 'Enter full name or username',
                ctrl: _searchCtrl,
                onClear: _onClear,
                onChanged: (value) {
                  if (_loadingBottom) return;

                  value = value.trim();
                  if (_searchQ == value) return;

                  if (value.length > 2) {
                    _debouncer.call(() async {
                      setState(() {
                        _trailsExt.clear();
                        _loadingSkeletons = true;
                        _searchQ = value;
                      });

                      _fetchPeople();
                    });
                  } else if (value == '') {
                    _onClear();
                  }
                },
              ),
            ),
            10.h,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sort_by_alpha_rounded,
                  size: 15,
                  color: AppTheme.clText05,
                ),
                6.w,
                const Text(
                  'Sorted by nearby your city',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.clText05,
                  ),
                ),
              ],
            ),
            10.h,
            Expanded(
              child: AppSimpleScaffold(
                scrollCtrl: _ctrl,
                physics: trailsExt.isEmpty
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                onRefresh: () async {
                  setState(() {
                    _loadingTop = true;
                  });

                  _fetchPeople(offset: 0);
                },
                onLoadMore: () async {
                  setState(() {
                    _loadingBottom = true;
                  });

                  _fetchPeople();
                },
                loadingBottom: _loadingBottom,
                loadingTop: _loadingTop,
                children: [
                  if ((_loadingSkeletons ||
                          _searchQ == null ||
                          _searchQ == '') &&
                      trailsExt.isEmpty) ...[
                    10.h,
                    fnUserSkeleton(context, _searchQ == null || _searchQ == ''),
                  ] else ...[
                    if (trailsExt.isEmpty)
                      Container(
                        width: context.width,
                        height: 150,
                        color: AppTheme.clBackground,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Container(
                          alignment: Alignment.topCenter,
                          child: Text(
                            (_searchQ == null || _searchQ!.trim().isEmpty)
                                ? ''
                                : 'No people found',
                            style: const TextStyle(
                              color: AppTheme.clText08,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        color: AppTheme.clBackground,
                        child: Column(
                          children: [
                            10.h,
                            for (var trailExt in trailsExt) ...[
                              ProfileRlship(trailExt: trailExt),
                              12.hrr(
                                height: 1.5,
                                color: AppTheme.clBlack,
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
