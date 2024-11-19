// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/text.dart';

@deprecated
class AppOption extends StatefulWidget {
  const AppOption({
    super.key,
    required this.title,
    this.subtitle,
    this.more = false,
    this.isDark = true,
    this.opts = const ['No', 'Yes'],
  });

  final String title;
  final String? subtitle;
  final bool more;
  final bool isDark;
  final List<String> opts;

  @override
  State<AppOption> createState() => _AppOptionState();
}

class _AppOptionState extends State<AppOption> {
  late String gender2;

  @override
  void initState() {
    gender2 = widget.opts.first;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.tsRegular(widget.title)
                  .tsFontSize(17)
                  .tsFontWeight(FontWeight.bold),
              CupertinoSlidingSegmentedControl<String>(
                backgroundColor: AppTheme.clBlack,
                thumbColor: AppTheme.clBackground,
                groupValue: gender2,
                onValueChanged: (String? value) {
                  setState(() {
                    gender2 = value!;
                  });
                },
                children: <String, Widget>{
                  widget.opts.first: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: 38,
                    child: Center(
                      child: Text(
                        widget.opts.first,
                        style: TextStyle(
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                            color: gender2 == widget.opts.first
                                ? AppTheme.clText08
                                : AppTheme.clText05),
                      ),
                    ),
                  ),
                  widget.opts.last: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: 38,
                    child: Center(
                      child: Text(
                        widget.opts.last,
                        style: TextStyle(
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                            color: gender2 == widget.opts.last
                                ? AppTheme.clYellow08
                                : AppTheme.clText05),
                      ),
                    ),
                  ),
                },
              ),
            ],
          ),
        ),
        if (widget.subtitle != null) ...[
          8.h,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.centerLeft,
            child: AppText.tsRegular(widget.subtitle)
                .tsFontSize(14)
                .tsColor(AppTheme.clText.withOpacity(0.8))
                .tsHeight(1.4),
          ),
        ],
        if (gender2 == widget.opts.last && widget.more) ...[
          10.h,
          const AppOption(title: 'Best Friend'),
        ],
      ],
    );
  }
}
