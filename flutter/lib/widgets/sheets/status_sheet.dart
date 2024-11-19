// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class StatusSheet extends StatefulWidget {
  const StatusSheet({super.key});

  @override
  State<StatusSheet> createState() => _StatusSheetState();
}

class _StatusSheetState extends State<StatusSheet> {
  @override
  Widget build(BuildContext context) {
    String code = '0';
    String message = 'Unknown';

    if (stVM.isError) {
      code = stVM.error!.code;
      message = stVM.error!.message;
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        stVM.clearError();
      },
      child: AppBottomScaffold(
        title: 'Error: $code',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
              15.h,
              10.hrr(height: 2, padLR: AppTheme.appLR * 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppSimpleButton(
                      onTry: () async {
                        AppRoute.goSheetTo('/error404_support');
                      },
                      width: context.width / 2,
                      height: AppTheme.appBtnHeight - 5,
                      text: 'Contact Support',
                    ),
                    20.w,
                    AppSimpleButton(
                      onTry: () async {
                        if (stVM.isError) {
                          AppRoute.goSheetTo('/error404_bug');
                        }
                      },
                      enable: stVM.isError,
                      width: 70,
                      icon: Icon(
                        Icons.bug_report_outlined,
                        size: 20,
                        color:
                            stVM.isError ? AppTheme.clText : AppTheme.clText03,
                      ),
                      height: AppTheme.appBtnHeight - 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
