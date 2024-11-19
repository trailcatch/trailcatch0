// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class AgeGroupsSheet extends StatefulWidget {
  const AgeGroupsSheet({
    super.key,
    required this.ageGroup,
  });

  final String ageGroup;

  @override
  State<AgeGroupsSheet> createState() => _AgeGroupsSheetState();
}

class _AgeGroupsSheetState extends State<AgeGroupsSheet> {
  late List<(String, List<int>)> _ageGroups;

  late String _preSelected;
  late String _selected;
  late int _inx;

  @override
  void initState() {
    _ageGroups = fnAgeGroups(allGroups: true);

    _selected = widget.ageGroup;
    if (_selected.isEmpty) _selected = _ageGroups.last.$1;

    _preSelected = _selected;

    _inx = _ageGroups.indexWhere((it) => it.$1 == _selected);
    if (_inx == -1) _inx = _ageGroups.length - 1;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomScaffold(
      title: 'Age Group',
      isChanged: _preSelected != _selected,
      onBack: () => _selected,
      child: Column(
        children: [
          SizedBox(
            height: 190,
            width: context.width,
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                brightness: Brightness.dark,
                applyThemeToAll: true,
                textTheme: CupertinoTextThemeData(
                  textStyle: AppTheme.tsRegular,
                  dateTimePickerTextStyle: AppTheme.tsMedium,
                  pickerTextStyle: AppTheme.tsMedium,
                ),
              ),
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: _inx,
                ),
                onSelectedItemChanged: (int value) {
                  setState(() {
                    _inx = value;
                    _selected = _ageGroups[_inx].$1;
                  });
                },
                children: [
                  for (var ageGroup in _ageGroups)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        ageGroup.$1,
                        style: TextStyle(
                          fontSize: _selected == ageGroup.$1 ? 20 : 17,
                          color: _selected == ageGroup.$1
                              ? AppTheme.clText
                              : AppTheme.clText07,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
