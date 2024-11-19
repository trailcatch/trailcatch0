// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/route.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';
import 'package:trailcatch/widgets/text.dart';

class SettingsLinkedAccountsScreen extends StatefulWidget {
  const SettingsLinkedAccountsScreen({super.key});

  @override
  State<SettingsLinkedAccountsScreen> createState() =>
      _SettingsLinkedAccountsScreenState();
}

class _SettingsLinkedAccountsScreenState
    extends State<SettingsLinkedAccountsScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return AppSimpleScaffold(
      title: 'Linked Accounts',
      loading: _loading,
      children: [
        10.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: AppText.tsRegular(
            'With TrailCatch, you can link your other social accounts to your TrailCatch profile. This gives you the flexibility to sign in using any of these services as an additional login option for your existing TrailCatch account, allowing you to choose the method that works best for you, anytime.',
          ),
        ),
        10.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: AppText.tsRegular(
            'Your linked social account must have the same email address as your currently logged-in TrailCatch account.',
          ),
        ),
        15.hrr(),
        for (var provider in [
          'apple',
          'google',
          'facebook',
          'twitter',
          'github',
          'discord'
        ]) ...[
          LayoutBuilder(builder: (context, _) {
            String providerStr = fnProviderToString(provider);
            bool isLinked = appVM.authProviders!.$2.contains(provider);
            bool isLogged = appVM.authProviders!.$1 == provider &&
                (appVM.authProviders!.$2.length == 1 &&
                    appVM.authProviders!.$2.first == provider);

            String textStr = 'Link with $providerStr';
            if (isLinked) {
              textStr = 'Linked with $providerStr';
            }
            if (isLogged) {
              textStr = 'Logged with $providerStr';
            }

            return Column(
              children: [
                Stack(
                  children: [
                    AppSimpleButton(
                      text: textStr,
                      width: context.width * AppTheme.appBtnWidth,
                      textColor: isLogged ? AppTheme.clYellow : null,
                      borderColor: isLogged
                          ? AppTheme.clYellow
                          : (isLinked ? AppTheme.clText08 : null),
                      fontWeight:
                          isLinked ? FontWeight.bold : FontWeight.normal,
                      onTry: () async {
                        if (fnIsDemo(silence: false)) return;

                        if (isLogged) {
                          AppRoute.showPopup(
                            [
                              AppPopupAction(
                                'Log Out',
                                color: AppTheme.clRed,
                                () async {
                                  await appVM.signOut();
                                },
                              ),
                            ],
                          );
                        } else if (isLinked) {
                          AppRoute.showPopup(
                            [
                              AppPopupAction(
                                'Unlink from $providerStr',
                                color: AppTheme.clRed,
                                () async {
                                  await authServ.unlinkWithOAuth(provider);
                                  await appVM.reAuthMyself(refresh: true);
                                  appVM.notify();

                                  setState(() {});

                                  fnShowToast('Unlinked');
                                },
                              ),
                            ],
                          );
                        } else {
                          AppRoute.showPopup(
                            [
                              AppPopupAction(
                                'Link with $providerStr',
                                color: AppTheme.clYellow,
                                () async {
                                  await authServ.linkWithOAuth(provider);

                                  setState(() => _loading = true);
                                  await Future.delayed(1500.mlsec);

                                  await appVM.reAuthMyself(refresh: true);
                                  appVM.notify();

                                  setState(() => _loading = false);
                                },
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    Positioned(
                      top: 12,
                      left: 10,
                      child: Image.asset(
                        'assets/***/***/${provider}_icon.png',
                        height: 20,
                        width: 20,
                        color: !['facebook', 'google'].contains(provider)
                            ? Colors.white
                            : null,
                      ),
                    ),
                  ],
                ),
                0.dl,
              ],
            );
          }),
        ],
      ],
    );
  }
}
