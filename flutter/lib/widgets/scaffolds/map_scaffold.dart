// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/screens/root/drawer.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/bottom_nav.dart';
import 'package:trailcatch/widgets/progress_indicator.dart';

class AppMapScaffold extends StatelessWidget {
  const AppMapScaffold({
    super.key,
    required this.child,
    this.title,
    this.loading = false,
    this.actions,
    this.onBack,
    this.isBackBlack = false,
    required this.map,
    this.showBottom = true,
    this.blurBottom = false,
    this.tr = true,
    this.isTr = false,
  });

  final Widget child;
  final Widget? title;
  final bool loading;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool isBackBlack;
  final Widget map;
  final bool showBottom;
  final bool blurBottom;
  final bool tr;
  final bool isTr;

  @override
  Widget build(BuildContext context) {
    double bottomH = context.notch != 0 ? context.notch - 10 : 0;

    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          key: key,
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              map,
              SizedBox(
                width: context.width,
                height: context.height,
                child: Container(
                  // color: isTr ? Colors.black.withOpacity(0.75) : null,
                  color: isTr ? Colors.black.withOpacity(0.7) : null,
                  // decoration: const BoxDecoration(
                  //   border: Border(
                  //     top: BorderSide(width: 2, color: Colors.black),
                  //   ),
                  // ),
                  padding: EdgeInsets.only(bottom: context.keyboardHeight),
                  child: Column(
                    children: [
                      Container(
                        width: context.width,
                        color: tr ? Colors.transparent : AppTheme.clBackground,
                        padding: EdgeInsets.only(
                          left: onBack != null ? 13 : 16,
                          top: onBack != null
                              ? context.statusBar + 8
                              : context.statusBar + 1,
                          right: 6,
                        ),
                        child: onBack != null
                            ? Container(
                                alignment: Alignment.topCenter,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(right: 21),
                                      child: GestureDetector(
                                        onTap: onBack,
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: isBackBlack ? 31 : 30,
                                          color: isBackBlack
                                              ? Colors.black
                                              : AppTheme.clText,
                                        ),
                                      ),
                                    ),
                                    title!,
                                  ],
                                ),
                              )
                            : Container(
                                child: title ?? Container(),
                              ),
                      ),
                      child,
                    ],
                  ),
                ),
                // child: KeyboardVisibilityBuilder(builder: (_, isKeyboard) {
                //   return Container(
                //     padding: EdgeInsets.only(
                //       bottom: isKeyboard ? context.keyboardHeight : 0,
                //     ),
                //     child: child,
                //   );
                // }),
              ),
              if (showBottom && blurBottom)
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: context.width,
                    height: 75,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        blendMode: BlendMode.plus,
                        child: Container(),
                      ),
                    ),
                  ),
                ),
              // if (showBottom)
              //   Positioned(
              //     left: 0,
              //     bottom: 0,
              //     child: Container(
              //       color: tr ? Colors.transparent : AppTheme.clBackground,
              //       padding: EdgeInsets.only(bottom: bottomH),
              //       child: const AppBottomNav(),
              //     ),
              //   ),
              if (loading) const AppProgressIndicatorCenter(),
            ],
          ),
        ),
      ),
    );
  }
}
