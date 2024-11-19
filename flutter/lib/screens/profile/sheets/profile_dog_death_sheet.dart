// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';
import 'package:trailcatch/widgets/text.dart';

class ProfileDogDeathSheet extends StatefulWidget {
  const ProfileDogDeathSheet({
    super.key,
    required this.death,
  });

  final List<DateTime> death;

  @override
  State<ProfileDogDeathSheet> createState() => _ProfileDogDeathSheetState();
}

class _ProfileDogDeathSheetState extends State<ProfileDogDeathSheet> {
  late bool _isChanged;

  DateTime? _preValue;

  @override
  void initState() {
    _isChanged = false;

    if (widget.death.isNotEmpty) {
      _preValue = widget.death.first;
    } else {
      _isChanged = true;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime initialDate = DateTime(now.year, now.month);

    if (widget.death.isNotEmpty) {
      initialDate = widget.death.first;
    }

    return AppBottomScaffold(
      title: 'Dog Death Date',
      isChanged: _isChanged,
      onBack: () {
        widget.death.clear();
        widget.death.add(initialDate);
      },
      child: Column(
        children: [
          const Center(child: Text('Month and Year of your Dog Death Date:')),
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
              child: CupertinoDatePicker(
                itemExtent: 40,
                mode: CupertinoDatePickerMode.monthYear,
                onDateTimeChanged: (DateTime value) {
                  setState(() {
                    widget.death.clear();
                    widget.death.add(value);

                    _isChanged = _preValue?.compareTo(value) != 0;
                  });
                },
                initialDateTime: initialDate,
                maximumDate: DateTime(now.year, now.month),
                minimumDate: DateTime(1900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
