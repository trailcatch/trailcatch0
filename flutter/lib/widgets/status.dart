// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/viewmodels/status_viewmodel.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/buttons/widget_button.dart';

class AppStatus extends StatefulWidget {
  const AppStatus({super.key});

  @override
  State<AppStatus> createState() => _AppStatusState();
}

class _AppStatusState extends State<AppStatus> {
  @override
  void didChangeDependencies() {
    context.watch<StatusViewModel>();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Widget wStatus = Container();

    if (stVM.isError) {
      wStatus = Container(
        height: 40,
        width: context.width,
        decoration: const BoxDecoration(
          color: AppTheme.clBlack,
          border: Border(
            top: BorderSide(width: 2, color: AppTheme.clBlack),
            left: BorderSide(width: 2, color: AppTheme.clRed),
            right: BorderSide(width: 2, color: AppTheme.clRed),
            bottom: BorderSide(width: 2, color: AppTheme.clBlack),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: AppWidgetButton(
            onTap: () async {
              await stVM.unwrap();

              stVM.clearError();
              stVM.notify();
            },
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                '${stVM.error!.code}: ${stVM.error!.message}',
                style: const TextStyle(
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );
    }

    if (stVM.statusMsg.isNotEmpty) {
      wStatus = AppGestureButton(
        onTry: () async {
          stVM.statusMsgOnTap?.call();
        },
        child: Container(
          height: 40,
          width: context.width,
          decoration: const BoxDecoration(
            color: AppTheme.clBlack,
            border: Border(
              top: BorderSide(width: 2, color: AppTheme.clBlack),
              left: BorderSide(width: 2, color: AppTheme.clYellow),
              right: BorderSide(width: 2, color: AppTheme.clYellow),
              bottom: BorderSide(width: 2, color: AppTheme.clBlack),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                stVM.statusMsg,
                style: AppTheme.tsRegular.tsFontSize(17),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );
    }

    return wStatus;
  }
}
