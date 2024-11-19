// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/theme.dart';

class AppOptionButton extends StatelessWidget {
  const AppOptionButton({
    super.key,
    required this.value,
    required this.opts,
    this.vtitle,
    this.htitle,
    this.htwidth,
    this.htfontSize,
    this.textColor,
    this.activeColor,
    this.onValueChanged,
  });

  final String? value;
  final List<String> opts;
  final String? vtitle;
  final String? htitle;
  final double? htwidth;
  final double? htfontSize;
  final Color? textColor;
  final Color? activeColor;
  final Function(String? value)? onValueChanged;

  @override
  Widget build(BuildContext context) {
    double? htwidthh = htwidth;
    if (opts.first == 'Off' && opts.last == 'On') {
      htwidthh = context.width * 0.6;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (vtitle != null) ...[
          Text(
            vtitle!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          10.h,
        ],
        SizedBox(
          width: context.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (htitle != null)
                SizedBox(
                  width: htwidthh,
                  child: Text(
                    htitle!,
                    style: TextStyle(
                      fontSize: htfontSize ?? 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: CupertinoSlidingSegmentedControl<String>(
                  backgroundColor: AppTheme.clBlack,
                  thumbColor: AppTheme.clBackground,
                  groupValue: value,
                  onValueChanged: (_) {},
                  children: <String, Widget>{
                    for (var opt in opts)
                      opt: GestureDetector(
                        onTap: () {
                          onValueChanged?.call(value != opt ? opt : null);
                        },
                        child: Center(
                          child: Container(
                            color: Colors.transparent,
                            height: AppTheme.appOptionHeigth,
                            alignment: Alignment.center,
                            child: Text(
                              opt,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: value == opt
                                    ? (activeColor ??
                                        (value == 'Off'
                                            ? AppTheme.clText
                                            : AppTheme.clYellow))
                                    : (textColor ?? AppTheme.clText03),
                              ),
                            ),
                          ),
                        ),
                      ),
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
