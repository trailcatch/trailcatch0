// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';

class ProfileBtns extends StatelessWidget {
  const ProfileBtns({
    super.key,
    required this.user,
    required this.fromRoot,
    required this.doRefresh,
  });

  final UserModel user;
  final bool fromRoot;
  final VoidCallback doRefresh;

  Future<void> _subscribe() async {
    trailVM.notify(loadingTop: true);

    await appVM.subscribeUser(user);
    await appVM.reFetchSettings();
    appVM.notify();

    await trailVM.reInitTrails();
    await trailVM.reFetchRlship0();
    await trailVM.reFetchRadar0();

    trailVM.notify(loadingTop: false);
  }

  Future<void> _removeRlship() async {
    trailVM.notify(loadingTop: true);

    await appVM.removeRlshipUser(user);
    await appVM.reFetchSettings();
    appVM.notify();

    await trailVM.reInitTrails();
    await trailVM.reFetchRlship0();
    await trailVM.reFetchRadar0();

    trailVM.notify(loadingTop: false);
  }

  Future<void> _hide() async {
    trailVM.notify(loadingTop: true);

    await appVM.hideUser(user);
    await appVM.reFetchSettings();
    appVM.notify();

    await trailVM.reInitTrails();
    await trailVM.reFetchRlship0();
    await trailVM.reFetchRadar0();

    trailVM.notify(loadingTop: false);
  }

  @override
  Widget build(BuildContext context) {
    String btnOtherFirstTitle = 'Subscribe';
    Color btnOtherFirstColor = AppTheme.clText;
    FontWeight btnOtherFirstFontWeight = FontWeight.normal;

    if (user.rlship == 1) {
      btnOtherFirstTitle = 'Subscribed';
      btnOtherFirstColor = AppTheme.clYellow;
      btnOtherFirstFontWeight = FontWeight.bold;
    } else if (user.rlship == 0) {
      btnOtherFirstTitle = 'Hidden';
      btnOtherFirstColor = AppTheme.clRed;
      btnOtherFirstFontWeight = FontWeight.bold;
    }

    String trailsTitle = 'Trails';
    Color? trailsColor;

    int notPubLastCount = trailVM.lastTrailsNotPubIds().length;
    int myTrailsNotNP =
        trailVM.myTrailsExt.where((trl) => !trl.trail.notPub).length;

    if (notPubLastCount > 0) {
      trailsTitle = 'Trails  / +$notPubLastCount';
      trailsColor = AppTheme.clYellow;
    } else if (myTrailsNotNP == 0) {
      trailsTitle = 'Sync Trails';
      trailsColor = AppTheme.clYellow;
    }

    return Container(
      color: AppTheme.clBlack,
      width: context.width,
      padding:
          const EdgeInsets.symmetric(horizontal: AppTheme.appLR, vertical: 5),
      child: Row(
        children: [
          if (user.isMe && fromRoot) ...[
            Expanded(
              child: AppSimpleButton(
                text: trailsTitle,
                textColor: trailsColor,
                borderColor: trailsColor,
                onTap: () async {
                  final isRefresh = await AppRoute.goTo('/trails');
                  if (isRefresh ?? false) {
                    doRefresh();
                  }
                },
              ),
            ),
            10.w,
            Expanded(
              child: AppSimpleButton(
                text: 'Edit Profile',
                onTap: () async {
                  AppRoute.goTo('/profile_edit');
                },
              ),
            ),
          ] else ...[
            Expanded(
              child: AppSimpleButton(
                fontSize: 15,
                text: user.isMe ? 'My Account' : btnOtherFirstTitle,
                textColor: btnOtherFirstColor,
                fontWeight: btnOtherFirstFontWeight,
                enable: !user.isMe,
                onTap: () async {
                  List<AppPopupAction> acts = [];

                  if (user.rlship != null) {
                    if (user.rlship == 1) {
                      acts.add(
                        AppPopupAction(
                          'Unsubscribe',
                          color: AppTheme.clRed,
                          () async {
                            if (fnIsDemo(silence: false)) return;

                            fnHaptic();

                            await _removeRlship();

                            fnShowToast('Unsubscribed');
                          },
                        ),
                      );
                    } else if (user.rlship == 0) {
                      acts.add(AppPopupAction(
                        'Unhide',
                        color: AppTheme.clRed,
                        () async {
                          fnHaptic();

                          await _removeRlship();

                          fnShowToast('Unhided');
                        },
                      ));
                    }
                  } else {
                    fnHaptic();

                    await _subscribe();

                    fnShowToast('Subscribed');
                  }

                  if (acts.isNotEmpty) {
                    AppRoute.showPopup(acts);
                  }
                },
              ),
            ),
            10.w,
            Expanded(
              child: AppSimpleButton(
                text: user.contacts.isNotEmpty ? 'Contacts' : 'No Contacts',
                fontSize: 15,
                enable: user.contacts.isNotEmpty,
                fontWeight:
                    user.contacts.isEmpty ? FontWeight.bold : FontWeight.normal,
                onTap: () async {
                  AppRoute.showPopup(
                    [
                      for (var rec in UserContact.formatToList(
                        user.contacts,
                      ))
                        AppPopupAction(
                          rec.$1,
                          () async {
                            final url = rec.$2;
                            launchUrl(Uri.parse(url));
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
          10.w,
          AppSimpleButton(
            height: 35,
            width: 50,
            icon: const Icon(
              Icons.more_horiz,
              size: 18,
              color: AppTheme.clText,
            ),
            onTap: () async {
              AppRoute.showPopup(
                [
                  AppPopupAction(
                    'Share Profile',
                    () => appVM.shareProfile(user),
                  ),
                  AppPopupAction(
                    'Show Statistics',
                    () async {
                      AppRoute.goTo('/profile_statistics', args: {
                        'user': user,
                      });
                    },
                  ),
                  if (user.rlship != 0 && !user.isMe)
                    AppPopupAction(
                      'Hide Profile',
                      color: AppTheme.clRed,
                      () async {
                        if (fnIsDemo(silence: false)) return;

                        AppRoute.showPopup(
                          [
                            AppPopupAction(
                              'Hide Profile',
                              color: AppTheme.clRed,
                              () async {
                                fnHaptic();

                                await _hide();

                                fnShowToast('Hidden');
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  if (user.rlship == 0 && !user.isMe)
                    AppPopupAction(
                      'Unhide Profile',
                      color: AppTheme.clRed,
                      () async {
                        fnHaptic();

                        await _removeRlship();

                        fnShowToast('Unhided');
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
