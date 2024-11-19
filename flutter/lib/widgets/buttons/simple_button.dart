// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/buttons/widget_button.dart';

class AppSimpleButton extends StatelessWidget {
  const AppSimpleButton({
    super.key,
    this.text,
    this.onTap,
    this.onTry,
    this.width,
    this.height = AppTheme.appBtnHeight,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.padding,
    this.textColor,
    this.borderColor,
    this.icon,
    this.enable = true,
  });

  final String? text;
  final VoidCallback? onTap;
  final Future<dynamic> Function()? onTry;
  final double? width;
  final double? height;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsets? padding;
  final Color? textColor;
  final Color? borderColor;
  final Widget? icon;
  final bool enable;

  @override
  Widget build(BuildContext context) {
    return AppWidgetButton(
      onTap: () async {
        if (!enable) return;

        if (onTap != null) {
          onTap!.call();
        } else if (onTry != null) {
          return await fnTry(() async {
            return await onTry!.call();
          });
        }
      },
      child: Container(
        width: width ?? context.width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.clBlack,
          border: Border.all(
            width: 1,
            color:
                enable ? (borderColor ?? AppTheme.clText03) : AppTheme.clText02,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(AppTheme.appBtnRadius),
          ),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 5),
        child: Center(
          child: icon ??
              Text(
                text ?? 'Unknown',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: enable
                      ? (textColor ?? AppTheme.clText)
                      : AppTheme.clText03,
                ),
              ),
        ),
      ),
    );
  }
}
