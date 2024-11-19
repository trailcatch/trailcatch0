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

class ProfileBirthdaySheet extends StatefulWidget {
  const ProfileBirthdaySheet({
    super.key,
    required this.birthday,
  });

  final List<DateTime> birthday;

  @override
  State<ProfileBirthdaySheet> createState() => _ProfileBirthdaySheetState();
}

class _ProfileBirthdaySheetState extends State<ProfileBirthdaySheet> {
  late bool _isChanged;

  DateTime? _preValue;

  @override
  void initState() {
    _isChanged = false;

    if (widget.birthday.isNotEmpty) {
      _preValue = widget.birthday.first;
    } else {
      _isChanged = true;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime initialDate = DateTime(now.year - 16, now.month);

    String group = '';
    if (widget.birthday.isNotEmpty) {
      group = ': ${fnAgeGroupFromBirthdayOrAge(
        birthday: widget.birthday.first,
      )}';
      initialDate = widget.birthday.first;
    } else {
      group = ': ${fnAgeGroupFromBirthdayOrAge(
        birthday: initialDate,
      )}';
    }

    return AppBottomScaffold(
      title: 'Age Group$group',
      isChanged: _isChanged,
      onBack: () {
        widget.birthday.clear();
        widget.birthday.add(initialDate);
      },
      child: Column(
        children: [
          const Center(child: Text('Month and Year of your Birth Date:')),
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
                    widget.birthday.clear();
                    widget.birthday.add(value);

                    _isChanged = _preValue?.compareTo(value) != 0;
                  });

                  fnHaptic();
                },
                initialDateTime: initialDate,
                maximumDate: DateTime(now.year - 16, now.month),
                minimumDate: DateTime(now.year - 120, now.month),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
