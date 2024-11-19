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
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';

class AppPopupScaffold extends StatelessWidget {
  const AppPopupScaffold({
    super.key,
    required this.actions,
    this.bottoms,
    this.title,
  });

  final List<AppPopupAction> actions;
  final List<AppPopupAction>? bottoms;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Material(
        color: AppTheme.clTransparent,
        child: Container(
          color: AppTheme.clTransparent,
          width: context.width,
          alignment: Alignment.bottomCenter,
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: AppTheme.clBackground,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (title != null) ...[
                      8.h,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 17,
                            color: AppTheme.clText08,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      8.h,
                      0.hrr(height: 2),
                    ],
                    for (var action in actions)
                      Column(
                        children: [
                          AppGestureButton(
                            onTry: () async {
                              fnTry(() async {
                                await Navigator.of(context).maybePop();
                                await action.func.call();
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.clBackground.withOpacity(0.6),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                              ),
                              child: Text(
                                action.text,
                                style: TextStyle(
                                  fontSize: 21,
                                  color: action.selected
                                      ? AppTheme.clYellow08
                                      : action.color,
                                  fontWeight: action.selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          if (actions.indexOf(action) != actions.length - 1)
                            0.hrr(height: 2),
                        ],
                      ),
                  ],
                ),
              ),
              if (bottoms != null)
                for (var bottom in bottoms!) ...[
                  8.h,
                  AppGestureButton(
                    onTry: () async {
                      fnTry(() async {
                        await Navigator.of(context).maybePop();
                        await bottom.func.call();
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                        color: AppTheme.clBackground,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Text(
                        bottom.text,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: bottom.color,
                        ),
                      ),
                    ),
                  ),
                ],
              8.h,
              GestureDetector(
                onTap: Navigator.of(context).maybePop,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    color: AppTheme.clBackground,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              (context.notch + 10).h,
            ],
          ),
        ),
      ),
    );
  }
}
