// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/device_model.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/viewmodels/app_viewmodel.dart';
import 'package:trailcatch/widgets/buttons/field_button.dart';
import 'package:trailcatch/widgets/buttons/option_button.dart';
import 'package:trailcatch/widgets/header.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = false;

  @override
  void didChangeDependencies() {
    context.watch<AppViewModel>();

    super.didChangeDependencies();
  }

  void _doAppRefresh() {
    Future.delayed(250.mlsec, () {
      appVM.notify();
      trailVM.notify();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> notifs = [];

    if (appVM.settings.notifPushLikes) notifs.add('Likes');
    if (appVM.settings.notifPushSubscribers) notifs.add('Subscribers');
    if (notifs.isEmpty) notifs.add('Off');

    List<String> authProviders = appVM.authProviders!.$2;
    authProviders = authProviders.map((it) {
      if (it == 'github') return 'GitHub';
      return it.toTitle();
    }).toList();

    String devicesStr = 'Not connected';
    if (deviceVM.connDeviceIds.isNotEmpty) {
      devicesStr = deviceVM.connDeviceIds
          .map((deviceId) => DeviceId.formatToStr(deviceId))
          .join(', ');
    }

    String subrPlan = 'Free Plan';
    if (appVM.settings.isForever) {
      subrPlan = 'Forever Young';
    } else if (appVM.settings.isTrialActive) {
      subrPlan = 'Free 30-day Trial Plan';
    } else if (appVM.settings.isPremium) {
      subrPlan = 'Premium Plan';
    }

    String providerStr = fnProviderToString(appVM.settings.provider!);
    String joinedStr = 'Joined with $providerStr';
    String jFullName = appVM.auth.userMetadata?['full_name'] ?? '';
    String jEmail = appVM.auth.email ?? '';
    if (jFullName.isEmpty && appVM.settings.provider == 'apple') {
      jFullName = '${appVM.appleGivenName} ${appVM.appleFamilyName}';
      jEmail = appVM.appleEmail ?? '';
    }

    return AppSimpleScaffold(
      title: 'Settings',
      loading: _loading,
      children: [
        if (appVM.settings.provider != null) ...[
          AppHeader(
            title: joinedStr,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            margin: EdgeInsets.zero,
          ),
          if (jFullName.isNotEmpty)
            Container(
              width: context.width,
              height: 45,
              color: AppTheme.clBlack,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.appLR,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.clText05,
                          ),
                        ),
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.clText05,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            jFullName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            jEmail,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
        10.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            title: 'Language',
            text: fnLangCodeToName(appVM.lang),
            onTap: () {
              AppRoute.goTo('/settings_language');
            },
          ),
        ),
        0.dl,
        const AppHeader(title: 'Subscription'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            title: 'Plan',
            text: subrPlan,
            onTap: () {
              AppRoute.goTo('/settings_subscription');
            },
          ),
        ),
        15.hrr(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            text: 'Restore Purchases',
            down: true,
            onTap: () {
              AppRoute.showPopup(
                [
                  AppPopupAction(
                    'Restore Purchases',
                    () async {
                      setState(() => _loading = true);

                      await appVM.restorePurchases();

                      setState(() => _loading = false);
                    },
                  ),
                ],
              );
            },
          ),
        ),
        0.dl,
        const AppHeader(title: 'Measurements'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppOptionButton(
            htitle: 'Units',
            value: appVM.settings.msrunit == UserMeasurementUnit.km
                ? 'kilometers'
                : 'miles',
            opts: const ['kilometers', 'miles'],
            htwidth: context.width * 0.4,
            onValueChanged: (value) async {
              if (value == 'kilometers') {
                if (appVM.settings.msrunit != UserMeasurementUnit.km) {
                  appVM.settings.msrunit = UserMeasurementUnit.km;
                  setState(() {});

                  await userServ.fnUsersUpdate(
                    msrunit: UserMeasurementUnit.km,
                  );

                  _doAppRefresh();
                }
              } else if (value == 'miles') {
                if (appVM.settings.msrunit != UserMeasurementUnit.miles) {
                  appVM.settings.msrunit = UserMeasurementUnit.miles;
                  setState(() {});

                  await userServ.fnUsersUpdate(
                    msrunit: UserMeasurementUnit.miles,
                  );

                  _doAppRefresh();
                }
              }
            },
          ),
        ),
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppOptionButton(
            htitle: 'Start Week On',
            value: appVM.settings.fdayofweek == 1 ? 'Monday' : 'Sunday',
            opts: const ['Monday', 'Sunday'],
            htwidth: context.width * 0.4,
            onValueChanged: (value) async {
              if (value == 'Monday') {
                if (appVM.settings.fdayofweek != 1) {
                  appVM.settings.fdayofweek = 1;
                  setState(() {});

                  await userServ.fnUsersUpdate(fdayofweek: 1);
                  appVM.settings.refreshFirstDays();

                  _doAppRefresh();
                }
              } else if (value == 'Sunday') {
                if (appVM.settings.fdayofweek != 0) {
                  appVM.settings.fdayofweek = 0;
                  setState(() {});

                  await userServ.fnUsersUpdate(fdayofweek: 0);
                  appVM.settings.refreshFirstDays();

                  _doAppRefresh();
                }
              }
            },
          ),
        ),
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppOptionButton(
            htitle: 'Time Format',
            value: appVM.settings.timeformat == 24 ? '24 hours' : '12 hours',
            opts: const ['12 hours', '24 hours'],
            htwidth: context.width * 0.4,
            onValueChanged: (value) async {
              if (value == '12 hours') {
                if (appVM.settings.timeformat != 12) {
                  appVM.settings.timeformat = 12;
                  setState(() {});

                  await userServ.fnUsersUpdate(timeformat: 12);

                  _doAppRefresh();
                }
              } else if (value == '24 hours') {
                if (appVM.settings.timeformat != 24) {
                  appVM.settings.timeformat = 24;
                  setState(() {});

                  await userServ.fnUsersUpdate(timeformat: 24);

                  _doAppRefresh();
                }
              }
            },
          ),
        ),
        0.dl,
        const AppHeader(title: 'Notifications'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            title: 'Push Notifications',
            text: notifs.join(', '),
            onTap: () {
              AppRoute.goTo('/settings_notifications');
            },
          ),
        ),
        0.dl,
        const AppHeader(title: 'Connections'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            title: 'Subscribers',
            text: 'Count: ${appVM.user.subscribers}',
            onTap: () {
              AppRoute.goTo('/profile_rlship', args: {
                'user': appVM.user,
                'subscriptions': false,
                'hiddens': false,
              });
            },
          ),
        ),
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            title: 'Subscriptions',
            text: 'Count: ${appVM.user.subscriptions}',
            onTap: () {
              AppRoute.goTo('/profile_rlship', args: {
                'user': appVM.user,
                'subscriptions': true,
                'hiddens': false,
              });
            },
          ),
        ),
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            title: 'Hiddens',
            text: 'Count: ${appVM.settings.hiddens}',
            onTap: () {
              AppRoute.goTo('/profile_rlship', args: {
                'user': appVM.user,
                'subscriptions': false,
                'hiddens': true,
              });
            },
          ),
        ),
        0.dl,
        const AppHeader(title: 'Trails & Devices'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            title: 'Trails',
            text: 'Count: ${appVM.user.trails}',
            onTap: () {
              AppRoute.goTo('/trails');
            },
          ),
        ),
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            title: 'Devices',
            text: devicesStr,
            onTap: () async {
              await AppRoute.goTo('/devices');
              appVM.notify();
            },
          ),
        ),
        0.dl,
        const AppHeader(title: 'Account & Secure'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            title: 'Face ID & Passcode',
            text: appVM.settings.faceid == 0
                ? 'Always Require'
                : (appVM.settings.faceid == -1
                    ? 'Never'
                    : 'Require After ${appVM.settings.faceid} Minutes'),
            onTap: () {
              if (fnIsDemo(silence: false)) return;

              AppRoute.goTo('/settings_faceid');
            },
          ),
        ),
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            title: 'Linked Accounts',
            text: authProviders.isNotEmpty
                ? authProviders.map((it) => fnProviderToString(it)).join(', ')
                : 'No Linked Accounts',
            onTap: () {
              AppRoute.goTo('/settings_linked_accounts');
            },
          ),
        ),
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            title: 'App Tracking Transparency (ATT)',
            text: appVM.settings.appTrackingTransparency
                ? 'Allowed'
                : 'Not Allowed',
            onTap: () async {
              await fnAppSettings();
              appVM.notify();
            },
          ),
        ),
        0.dl,
        0.dl,
        const AppHeader(title: 'Danger Zone', isDanger: true),
        0.dl,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppFieldButton(
            text: 'Delete Account',
            onTap: () {
              AppRoute.goTo('/settings_delete_account');
            },
          ),
        ),
        0.dl,
      ],
    );
  }
}
