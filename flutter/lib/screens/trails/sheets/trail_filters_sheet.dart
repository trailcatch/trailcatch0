// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/buttons/field_button.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/buttons/option_button.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class TrailFiltersSheet extends StatefulWidget {
  const TrailFiltersSheet({
    super.key,
    required this.showFltStranges,
  });

  final bool showFltStranges;

  @override
  State<TrailFiltersSheet> createState() => _TrailFiltersSheetState();
}

class _TrailFiltersSheetState extends State<TrailFiltersSheet> {
  late TrailFilters _trailFilters;
  late bool _isChanged;

  @override
  void initState() {
    _trailFilters = TrailFilters.fromJson(trailVM.trailFilters.toJson());
    _isChanged = false;

    super.initState();
  }

  void _isChanged0() {
    _trailFilters.isChanged().then((value) async {
      setState(() {
        _isChanged = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String trailsStr = '';
    if (_trailFilters.trailType != null) {
      trailsStr = TrailType.formatToStr(_trailFilters.trailType)!;

      if (_trailFilters.withDogs == true) {
        trailsStr += ' & Dogs';
      }
    }

    String gendersStr = '';
    if (_trailFilters.genders.isNotEmpty) {
      gendersStr =
          _trailFilters.genders.map((gnd) => UserGender.format(gnd)).join(', ');
    }

    String ageGroupsStr = '';
    if (_trailFilters.ageGroups.isNotEmpty) {
      ageGroupsStr = _trailFilters.ageGroups.join(', ');
    }

    String nationalStr = '';
    if (_trailFilters.uiso3s.isNotEmpty) {
      if (_trailFilters.uiso3s.length <= 4) {
        nationalStr = _trailFilters.uiso3s
            .map((uiso3) => fnCountryNameByIso3(uiso3))
            .join(', ');
      } else {
        nationalStr = '${_trailFilters.uiso3s.length} countries';
      }
    }

    String dogsBreedStr = '';
    if (_trailFilters.dogsBreed.isNotEmpty) {
      if (_trailFilters.dogsBreed.length <= 3) {
        dogsBreedStr = _trailFilters.dogsBreed
            .map((dogsBreed) => fnDogBreedNameById(dogsBreed))
            .join(', ');
      } else {
        dogsBreedStr = '${_trailFilters.dogsBreed.length} dogs breeds';
      }
    }

    return AppBottomScaffold(
      title: 'Filters',
      isChanged: _isChanged,
      onBack: () async {
        if (_isChanged) {
          await _trailFilters.save();
          await trailVM.trailFilters.refresh();
        }

        return _isChanged;
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
            child: Row(
              children: [
                Expanded(
                  child: AppFieldButton(
                    title: 'Trails',
                    text: trailsStr,
                    placeholder: 'All Trails',
                    down: true,
                    onTap: () {
                      void onSelect(int trailType, bool? withDogs) {
                        if (_trailFilters.trailType != trailType ||
                            _trailFilters.withDogs != withDogs) {
                          _trailFilters.trailType = trailType;
                          _trailFilters.withDogs = withDogs;
                        } else {
                          _trailFilters.trailType = null;
                          _trailFilters.withDogs = null;
                        }

                        _isChanged0();
                      }

                      AppRoute.showPopup(
                        [
                          for (var trltp in TrailType.all) ...[
                            AppPopupAction(
                              TrailType.formatToStr(trltp) ?? '',
                              selected: _trailFilters.trailType == trltp &&
                                  _trailFilters.withDogs != true,
                              () async => onSelect(trltp, false),
                            ),
                            AppPopupAction(
                              '${TrailType.formatToStr(trltp)} & Dogs',
                              selected: _trailFilters.trailType == trltp &&
                                  _trailFilters.withDogs == true,
                              () async => onSelect(trltp, true),
                            ),
                          ]
                        ],
                      );
                    },
                  ),
                ),
                if (_trailFilters.trailType != null) ...[
                  8.w,
                  Container(
                    color: AppTheme.clBackground,
                    padding: const EdgeInsets.only(top: 23),
                    child: AppGestureButton(
                      child: const Icon(Icons.close, color: AppTheme.clRed),
                      onTap: () {
                        _trailFilters.trailType = null;
                        _trailFilters.withDogs = null;

                        _isChanged0();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.showFltStranges) 0.dl,
          if (widget.showFltStranges)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.appLR + 2),
              child: AppOptionButton(
                htitle: 'Nearby',
                htwidth: context.width * 0.25,
                htfontSize: 15,
                value: _trailFilters.strangesOnly == true
                    ? 'Stranges Only'
                    : 'Everyone',
                opts: const ['Everyone', 'Stranges Only'],
                onValueChanged: (value) async {
                  if (value == 'Stranges Only') {
                    _trailFilters.strangesOnly = true;
                  } else if (value == 'Everyone') {
                    _trailFilters.strangesOnly = null;
                  }

                  _isChanged0();
                },
              ),
            ),
          20.h,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
            child: Row(
              children: [
                Expanded(
                  child: AppFieldButton(
                    title: 'Genders',
                    text: gendersStr,
                    placeholder: 'All Genders',
                    down: true,
                    onTap: () {
                      void onSelect(int gender) {
                        if (_trailFilters.genders.contains(gender)) {
                          _trailFilters.genders.remove(gender);
                        } else {
                          _trailFilters.genders.add(gender);
                          _trailFilters.genders.sort();
                        }

                        _isChanged0();
                      }

                      AppRoute.showPopup(
                        [
                          for (var gndr in UserGender.all..remove(0))
                            AppPopupAction(
                              UserGender.format(gndr),
                              selected: _trailFilters.genders.contains(gndr),
                              () async => onSelect(gndr),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                if (_trailFilters.genders.isNotEmpty) ...[
                  8.w,
                  Container(
                    color: AppTheme.clBackground,
                    padding: const EdgeInsets.only(top: 23),
                    child: AppGestureButton(
                      child: const Icon(Icons.close, color: AppTheme.clRed),
                      onTap: () {
                        _trailFilters.genders.clear();

                        _isChanged0();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          0.dl,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
            child: Row(
              children: [
                Expanded(
                  child: AppFieldButton(
                    title: 'Age Groups',
                    text: ageGroupsStr,
                    placeholder: 'All Age Groups',
                    down: true,
                    onTap: () {
                      void onSelect((String, List<int>) aggrp) {
                        if (_trailFilters.ageGroups.contains(aggrp.$1)) {
                          _trailFilters.ageGroups.remove(aggrp.$1);
                        } else {
                          _trailFilters.ageGroups.add(aggrp.$1);
                          _trailFilters.ageGroups.sort();
                        }

                        _isChanged0();
                      }

                      AppRoute.showPopup(
                        [
                          for (var aggrp in fnAgeGroupsS())
                            AppPopupAction(
                              aggrp.$1,
                              selected: _trailFilters.ageGroups.contains(
                                aggrp.$1,
                              ),
                              () async => onSelect(aggrp),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                if (_trailFilters.ageGroups.isNotEmpty) ...[
                  8.w,
                  Container(
                    color: AppTheme.clBackground,
                    padding: const EdgeInsets.only(top: 23),
                    child: AppGestureButton(
                      child: const Icon(Icons.close, color: AppTheme.clRed),
                      onTap: () {
                        _trailFilters.ageGroups.clear();

                        _isChanged0();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          0.dl,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
            child: Row(
              children: [
                Expanded(
                  child: AppFieldButton(
                    title: 'Nationalities',
                    placeholder: 'All Nationalities',
                    text: nationalStr,
                    onTap: () async {
                      final uiso3s =
                          await AppRoute.goTo('/profile_countries', args: {
                        'uiso3s': _trailFilters.uiso3s,
                        'multiSelect': true,
                      });

                      if (uiso3s != null) {
                        _trailFilters.uiso3s = List<String>.from(uiso3s);

                        _isChanged0();
                      }
                    },
                  ),
                ),
                if (_trailFilters.uiso3s.isNotEmpty) ...[
                  8.w,
                  Container(
                    color: AppTheme.clBackground,
                    padding: const EdgeInsets.only(top: 23),
                    child: AppGestureButton(
                      child: const Icon(Icons.close, color: AppTheme.clRed),
                      onTap: () {
                        _trailFilters.uiso3s.clear();

                        _isChanged0();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          0.dl,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
            child: Row(
              children: [
                Expanded(
                  child: AppFieldButton(
                    title: 'Dog Breeds',
                    placeholder: 'All Dog Breeds',
                    text: dogsBreedStr,
                    onTap: () async {
                      final List? res = await AppRoute.goTo(
                        '/profile_dogs_breed',
                        args: {
                          'dogsBreed': _trailFilters.dogsBreed,
                          'multiSelect': true,
                        },
                      );

                      if (res != null) {
                        _trailFilters.dogsBreed = List<int>.from(res);

                        _isChanged0();
                      }
                    },
                  ),
                ),
                if (_trailFilters.dogsBreed.isNotEmpty) ...[
                  8.w,
                  Container(
                    color: AppTheme.clBackground,
                    padding: const EdgeInsets.only(top: 23),
                    child: AppGestureButton(
                      child: const Icon(Icons.close, color: AppTheme.clRed),
                      onTap: () {
                        _trailFilters.dogsBreed.clear();

                        _isChanged0();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
