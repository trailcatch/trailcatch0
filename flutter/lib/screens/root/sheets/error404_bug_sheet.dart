// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class Error404BugSheet extends StatelessWidget {
  const Error404BugSheet({super.key});

  @override
  Widget build(BuildContext context) {
    String msg = stVM.error?.toString() ?? 'Unknown';
    msg += '\n\n';
    msg += 'time: ${DateTime.now().toUtc().toIso8601String()}';
    msg += '\nmsg: ';
    msg += stVM.error?.toStringF() ?? '-1';
    msg += '\n\n- - -\n\n';
    msg += stVM.error?.stack.toString() ?? 'No stack';

    return AppBottomScaffold(
      title: 'Report Bug',
      padTop: 0,
      padBottom: 0,
      heightTop: 0,
      child: SizedBox(
        height: context.height * 0.815,
        width: context.width,
        child: Scaffold(
          backgroundColor: AppTheme.clBackground,
          body: Builder(builder: (ctx) {
            return Column(
              children: [
                0.hrr(height: 2),
                10.h,
                Expanded(
                  child: Container(
                    height: context.height * 0.5,
                    width: context.width,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppTheme.appLR,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.appLR,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.clBlack,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          10.h,
                          Text(msg),
                          10.h,
                        ],
                      ),
                    ),
                  ),
                ),
                20.h,
                AppSimpleButton(
                  onTry: () async {
                    AppRoute.showPopup(
                      [
                        AppPopupAction(
                          'Send Email',
                          () async {
                            var url = Uri.parse(
                              'mailto:team@trailcatch.com?subject=Bug%20Report&body=msg',
                            );
                            await launchUrl(url);
                          },
                        ),
                        AppPopupAction(
                          'Share & Send',
                          () async {
                            await Share.share(
                              msg,
                              subject: 'TrailCatch Bug Report',
                            );
                          },
                        ),
                        AppPopupAction(
                          'Copy to Clipboard',
                          () async {
                            try {
                              Clipboard.setData(ClipboardData(text: msg));

                              fnShowToast(
                                'Copied to clipboard.',
                                context: ctx,
                              );
                            } catch (_) {
                              fnShowToast(
                                'Failed to copy to clipboard.',
                                context: ctx,
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                  width: context.width * AppTheme.appBtnWidth,
                  text: 'Report Bug',
                  enable: stVM.isError,
                ),
                (context.notch + 10).h,
              ],
            );
          }),
        ),
      ),
    );
  }
}
