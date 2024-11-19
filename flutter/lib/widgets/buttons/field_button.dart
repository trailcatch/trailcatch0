// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/buttons/widget_button.dart';

class AppFieldButton extends StatelessWidget {
  const AppFieldButton({
    super.key,
    this.title = '',
    this.placeholder = '',
    required this.text,
    this.down = false,
    this.onTap,
    this.onTry,
  });

  final String title;
  final String placeholder;
  final String text;
  final bool down;
  final VoidCallback? onTap;
  final Future<dynamic> Function()? onTry;

  factory AppFieldButton.gender(
    BuildContext context, {
    required int gender,
    required Function(int value) onSelect,
  }) {
    return AppFieldButton(
      title: 'Gender',
      text: UserGender.format(gender),
      placeholder: 'Gender',
      down: true,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());

        AppRoute.showPopup(
          title: 'Gender',
          [
            for (var gdr in UserGender.all)
              AppPopupAction(
                UserGender.format(gdr),
                selected: gdr == gender,
                () async => onSelect(gdr),
              ),
          ],
        );
      },
    );
  }

  factory AppFieldButton.ageGroup(
    BuildContext context, {
    required DateTime? birthday,
    required int? gender,
    required Function(DateTime value) onSelect,
  }) {
    return AppFieldButton(
      title: 'Age Group',
      text: birthday == null || gender == null
          ? ''
          : fnAgeGroup(
              gender: gender,
              age: fnAge(birthday),
            ),
      placeholder: 'Age Group',
      down: true,
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());

        List<DateTime> birthday0 = [];
        if (birthday != null) birthday0.add(birthday);

        await AppRoute.goSheetTo('/profile_birthday', args: {
          'birthday': birthday0,
        });

        if (birthday0.isNotEmpty) {
          onSelect(birthday0.first);
        }
      },
    );
  }

  factory AppFieldButton.ageGroups(
    BuildContext context, {
    required int? gender,
    required String ageGroup,
    required Function(String value) onSelect,
  }) {
    String text = 'All groups';
    if (gender != null && ageGroup.isNotEmpty && ageGroup != text) {
      text = UserGender.format(gender, short: true).trim();
      text += ' $ageGroup';
    }

    return AppFieldButton(
      title: 'Age Group',
      text: text,
      placeholder: 'Age Group',
      down: true,
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());

        final selected = await AppRoute.goSheetTo('/age_groups', args: {
          'ageGroup': ageGroup,
        });

        if (selected != null) {
          onSelect(selected);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.only(left: 3),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                letterSpacing: 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          1.h
        ],
        AppWidgetButton(
          onTap: () async {
            if (onTap != null) {
              onTap!.call();
            } else if (onTry != null) {
              return await fnTry(() async {
                return await onTry!.call();
              });
            }
          },
          child: Stack(
            children: [
              Container(
                width: context.width,
                height: AppTheme.appTextFieldHeight,
                decoration: BoxDecoration(
                  color: AppTheme.clBlack,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppTheme.appBtnRadius),
                  ),
                  border: Border.all(
                    width: 1,
                    color: AppTheme.clBlack,
                  ),
                ),
                padding: const EdgeInsets.only(left: 10, right: 25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text.isNotEmpty ? text : placeholder,
                    style: TextStyle(
                      fontFamily: AppTheme.ffUbuntuLight,
                      fontSize: 15,
                      letterSpacing: 0.2,
                      color: text.isEmpty ? AppTheme.clText05 : AppTheme.clText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Positioned(
                right: 3,
                top: 6,
                child: RotatedBox(
                  quarterTurns: down ? 1 : 0,
                  child: const Icon(
                    Icons.arrow_right,
                    size: 26,
                    color: AppTheme.clText,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class AppFieldButtonGender extends StatelessWidget {
  const AppFieldButtonGender({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
