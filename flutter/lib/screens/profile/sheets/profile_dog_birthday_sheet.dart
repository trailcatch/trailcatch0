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
import 'package:trailcatch/widgets/text.dart';

class ProfileDogBirthdaySheet extends StatefulWidget {
  const ProfileDogBirthdaySheet({
    super.key,
    required this.birthday,
  });

  final List<DateTime> birthday;

  @override
  State<ProfileDogBirthdaySheet> createState() =>
      _ProfileDogBirthdaySheetState();
}

class _ProfileDogBirthdaySheetState extends State<ProfileDogBirthdaySheet> {
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
    DateTime initialDate = DateTime(now.year, now.month);

    String age = '';
    if (widget.birthday.isNotEmpty) {
      DateTime? death;
      if (widget.birthday.length == 2) {
        death = widget.birthday.last;
      }

      age = ': ${fnAge(widget.birthday.first, death: death)}';
      initialDate = widget.birthday.first;
    } else {
      age = ': ${fnAge(initialDate)}';
    }

    if (age == ': 0') age = ': 0+';

    return AppBottomScaffold(
      title: 'Dog Age$age',
      isChanged: _isChanged,
      onBack: () {
        widget.birthday.clear();
        widget.birthday.add(initialDate);
      },
      child: Column(
        children: [
          const Center(child: Text('Month and Year of your Dog Birth Date:')),
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