// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';

class AppBottomScaffold extends StatelessWidget {
  const AppBottomScaffold({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
    this.isChanged = false,
    this.padTop = 10,
    this.padBottom,
    this.heightTop = 3,
  });

  final String title;
  final Widget child;
  final dynamic Function()? onBack;
  final bool isChanged;
  final double padTop;
  final double? padBottom;
  final double heightTop;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        child: Container(
          color: AppTheme.clBackground,
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                width: 60,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.clText2.withOpacity(0.3),
                ),
              ),
              FittedBox(
                child: Container(
                  color: AppTheme.clBackground,
                  child: SizedBox(
                    width: context.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                color: AppTheme.clBackground,
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: title.startsWith('Error')
                                        ? AppTheme.clRed
                                        : AppTheme.clText,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  dynamic res = await onBack?.call();
                                  AppRoute.goSheetBack(res);
                                },
                                child: Container(
                                  width: 40,
                                  color: AppTheme.clBackground,
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      isChanged
                                          ? Icons.done_all
                                          : Icons.close_rounded,
                                      size: 28,
                                      color:
                                          isChanged ? AppTheme.clYellow : null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        8.h,
                        0.hrr(height: heightTop),
                        Container(
                          padding: EdgeInsets.only(
                            top: padTop,
                            bottom: padBottom ?? context.notch + 10,
                          ),
                          child: child,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
