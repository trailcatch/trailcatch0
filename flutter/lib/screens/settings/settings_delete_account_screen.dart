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
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/header.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class SettingsDeleteAccountScreen extends StatelessWidget {
  const SettingsDeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSimpleScaffold(
      title: 'Delete Account',
      children: [
        const AppHeader(title: 'Danger Zone', margin: EdgeInsets.zero),
        30.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          alignment: Alignment.center,
          child: const Text(
            'Your account will be deleted permamently.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.clText,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        8.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          alignment: Alignment.center,
          child: const Text(
            'You will not be able to restore it.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.clText,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        30.h,
        0.hrr(height: 1, color: AppTheme.clRed02),
        0.hrr(height: 3),
        0.hrr(height: 1, color: AppTheme.clRed02),
        20.h,
        Container(
          width: context.width * AppTheme.appBtnWidth,
          alignment: Alignment.center,
          child: AppSimpleButton(
            text: 'Delete Account',
            textColor: AppTheme.clRed,
            borderColor: AppTheme.clRed06,
            onTap: () async {
              if (fnIsDemo(silence: false)) return;

              AppRoute.showPopup(
                title: 'Are you sure want to delete your account?',
                [
                  AppPopupAction(
                    'Yes, I\'m Sure.',
                    color: AppTheme.clRed,
                    () async {
                      bool isOk = true;

                      if (appVM.settings.faceid != -1 &&
                          (await fnIsFaceIdSupported())) {
                        isOk = await AppRoute.goTo('/pin', args: {
                          'canGoBack': true,
                          'showPinDesc': false,
                        });
                      }

                      if (isOk) {
                        AppRoute.showPopup(
                          title:
                              'Your account will be deleted permamently.\nYou will not be able to restore it.',
                          [
                            AppPopupAction(
                              'Yes, Delete My Account.',
                              color: AppTheme.clRed,
                              () async {
                                try {
                                  storageServ.deleteLocalPictureUUID(
                                    uuid: appVM.user.userId,
                                  );

                                  storageServ.deletePictureUUID(
                                    userId: appVM.user.userId,
                                    uuid: appVM.user.userId,
                                  );

                                  for (var dog0 in appVM.user.dogs0) {
                                    storageServ.deletePictureUUID(
                                      userId: appVM.user.userId,
                                      uuid: dog0.dogId,
                                    );
                                  }
                                } catch (_) {}

                                await appVM.deleteAccount();

                                AppRoute.goTo(
                                  '/settings_delete_last_account',
                                );
                              },
                            )
                          ],
                        );
                      } else {
                        return;
                      }
                    },
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
