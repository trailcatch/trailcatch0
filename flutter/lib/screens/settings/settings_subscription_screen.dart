// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qonversion_flutter/qonversion_flutter.dart';

import 'package:trailcatch/constants.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/viewmodels/app_viewmodel.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';
import 'package:trailcatch/widgets/tcid.dart';

class SettingsSubscriptionScreen extends StatefulWidget {
  const SettingsSubscriptionScreen({super.key});

  @override
  State<SettingsSubscriptionScreen> createState() =>
      _SettingsSubscriptionScreenState();
}

class _SettingsSubscriptionScreenState
    extends State<SettingsSubscriptionScreen> {
  bool _loading = false;

  @override
  void didChangeDependencies() {
    context.watch<AppViewModel>();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (appVM.settings.isForever) {
      return AppSimpleScaffold(
        title: 'Subscriptions',
        children: [
          15.h,
          Text(
            'Forever Young!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          0.dl,
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppTheme.appLR,
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.appLR, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: AppTheme.clBlack,
            ),
            child: Column(
              children: [
                Text(
                  'The Free Forever Plan is a gift to you.',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                6.h,
                Text(
                  'Thank you for being my friend!',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    String expireStatus = '';
    DateTime? expirationDate = appVM.plan?.expirationDate;
    bool willRenew = appVM.plan?.renewState == QEntitlementRenewState.willRenew;
    if (expirationDate != null) {
      if (willRenew) {
        expireStatus =
            'Renewal is scheduled to take place \n at ${expirationDate.toTime()}, ${expirationDate.toDate(
          isD: true,
          isY2: false,
        )}';
      } else {
        expireStatus = 'The expiration date is ${expirationDate.toDate(
          isD: true,
          isY2: true,
        )}';
      }
    }

    String premiumPrice = '0.00 USD/month';
    if (appVM.product != null && appVM.product!.price != null) {
      premiumPrice = appVM.product!.price!.toStringAsFixed(2);
      premiumPrice += ' ${appVM.product!.currencyCode}';
      premiumPrice += '/month';
    }

    return AppSimpleScaffold(
      title: 'Subscriptions',
      loading: _loading,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            10.h,
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.appLR,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: appVM.settings.isFree
                    ? AppTheme.clYellow005
                    : AppTheme.clText002,
                border: Border.symmetric(
                  vertical: BorderSide(
                    width: 2,
                    color: appVM.settings.isFree
                        ? AppTheme.clYellow
                        : AppTheme.clBlack,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Free Plan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.clText,
                    ),
                  ),
                  0.dl,
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.appLR, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: AppTheme.clBlack,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'With the Free Plan, you can publish only up to $cstFreeTrailPerWeek trails per week.',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        15.h,
                        EmptyFreeTrails(),
                      ],
                    ),
                  ),
                  10.h,
                  AppSimpleButton(
                    text: 'Restore Purchases',
                    width: context.width * AppTheme.appBtnWidth,
                    onTap: () async {
                      setState(() => _loading = true);
                      await Future.delayed(250.mlsec);

                      await appVM.restorePurchases();

                      setState(() => _loading = false);
                    },
                  ),
                ],
              ),
            ),
            20.h,
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.appLR,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: appVM.settings.isPremium
                    ? AppTheme.clYellow005
                    : AppTheme.clText002,
                border: Border.symmetric(
                  vertical: BorderSide(
                    width: 2,
                    color:
                        appVM.settings.isPremium || appVM.settings.isTrialActive
                            ? AppTheme.clYellow
                            : AppTheme.clBlack,
                  ),
                ),
              ),
              child: Column(
                children: [
                  if (appVM.settings.isTrialActive) ...[
                    Text(
                      'Free 30-day Trial Plan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (appVM.settings.trialAt != null)
                      Container(
                        padding: const EdgeInsets.only(top: 4),
                        alignment: Alignment.center,
                        child: Text(
                          'The expiration date is ${appVM.settings.trialAt!.add(const Duration(days: cstTrialDays)).toDate(
                                isD: true,
                                isY2: true,
                              )}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.clYellow07,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    10.h,
                  ],
                  Column(
                    children: [
                      Text(
                        'Premium Plan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: appVM.settings.isTrialActive
                              ? AppTheme.clText04
                              : AppTheme.clText,
                          decoration: appVM.settings.isTrialActive
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppTheme.clText07,
                        ),
                      ),
                      6.h,
                      Text(
                        premiumPrice,
                        style: TextStyle(
                          fontSize: 15,
                          color: appVM.settings.isTrialActive
                              ? AppTheme.clText04
                              : AppTheme.clText,
                          fontWeight: FontWeight.bold,
                          decoration: appVM.settings.isTrialActive
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppTheme.clText07,
                        ),
                      ),
                      if (expireStatus.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.only(top: 4),
                          alignment: Alignment.center,
                          child: Text(
                            expireStatus,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.clYellow07,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                  0.dl,
                  Opacity(
                    opacity: appVM.settings.isTrialActive ? 0.3 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.appLR, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: AppTheme.clBlack,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'With the Premium Plan, you can publish an unlimited number of trails per week.',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          15.h,
                          EmptyPremiumTrails(),
                        ],
                      ),
                    ),
                  ),
                  0.dl,
                  if (!appVM.settings.isPremium)
                    Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              if (appVM.settings.trialAt == null) ...[
                                AppSimpleButton(
                                  text: 'Try free 30-day Trial Plan',
                                  width: context.width * AppTheme.appBtnWidth,
                                  onTap: () async {
                                    final isYes = await AppRoute.goSheetTo(
                                      '/settings_subscription_trial',
                                    );

                                    if (isYes ?? false) {
                                      setState(() => _loading = true);

                                      await appVM.startTrial();

                                      setState(() => _loading = false);
                                    }
                                  },
                                ),
                                5.h,
                              ],
                              AppSimpleButton(
                                text: 'Purchase Premium Plan',
                                width: context.width * AppTheme.appBtnWidth,
                                textColor: AppTheme.clYellow,
                                borderColor: AppTheme.clYellow,
                                onTap: () async {
                                  final isYes = await AppRoute.goSheetTo(
                                    '/settings_subscription_premium',
                                    args: {'premiumPrice': premiumPrice},
                                  );

                                  if (isYes ?? false) {
                                    setState(() => _loading = true);
                                    await Future.delayed(250.mlsec);

                                    await appVM.purchasePremium();

                                    setState(() => _loading = false);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      alignment: Alignment.center,
                      child: AppSimpleButton(
                        text: 'Cancel Premium Plan',
                        width: context.width * AppTheme.appBtnWidth,
                        textColor: AppTheme.clRed,
                        borderColor: AppTheme.clRed,
                        onTap: () async {
                          AppRoute.showPopup(
                            [
                              AppPopupAction(
                                'Cancel Premium Plan',
                                color: AppTheme.clRed,
                                () async {
                                  await appVM.cancelPurchase();
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EmptyFreeTrails extends StatelessWidget {
  const EmptyFreeTrails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final trl1 = TrailModel.empty(
        trailId: '1',
        distance: 3400,
        time: 1212,
        type: 1,
        avgPace: 250,
        dogsIds: ['1'],
      );
      final trl2 = TrailModel.empty(
        trailId: '1',
        distance: 3440,
        time: 1812,
        type: 2,
        avgPace: 290,
      );

      return Opacity(
        opacity: 0.5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppTCID(height: 50, trail: trl1),
            15.w,
            AppTCID(height: 50, trail: trl2),
          ],
        ),
      );
    });
  }
}

class EmptyPremiumTrails extends StatelessWidget {
  const EmptyPremiumTrails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final trl1 = TrailModel.empty(
        trailId: '1',
        distance: 3400,
        time: 1212,
        type: 1,
        avgPace: 250,
        dogsIds: ['1'],
      );
      final trl2 = TrailModel.empty(
        trailId: '1',
        distance: 3440,
        time: 1812,
        type: 2,
        avgPace: 290,
      );
      final trl3 = TrailModel.empty(
        trailId: '1',
        distance: 6400,
        time: 2212,
        type: 3,
        avgSpeed: 150,
        dogsIds: ['1'],
      );
      final trl4 = TrailModel.empty(
        trailId: '1',
        distance: 5470,
        time: 6262,
        type: 2,
        avgPace: 150,
      );
      final trl5 = TrailModel.empty(
        trailId: '1',
        distance: 8400,
        time: 4212,
        type: 3,
        avgSpeed: 550,
        dogsIds: ['1'],
      );
      final trl6 = TrailModel.empty(
        trailId: '1',
        distance: 3400,
        time: 1212,
        type: 2,
        avgPace: 750,
        dogsIds: ['1'],
      );
      final trl7 = TrailModel.empty(
        trailId: '1',
        distance: 4400,
        time: 2442,
        type: 2,
        avgPace: 450,
        dogsIds: ['1'],
      );
      final trl8 = TrailModel.empty(
        trailId: '1',
        distance: 3400,
        time: 1212,
        type: 1,
        avgPace: 250,
        dogsIds: ['1'],
      );
      final trl9 = TrailModel.empty(
        trailId: '1',
        distance: 3400,
        time: 1212,
        type: 1,
        avgPace: 250,
        dogsIds: ['1'],
      );
      final trl10 = TrailModel.empty(
        trailId: '1',
        distance: 6400,
        time: 2882,
        type: 1,
        avgPace: 350,
      );

      return Opacity(
        opacity: 0.5,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              for (var trl in [
                trl1,
                trl2,
                trl3,
                trl4,
                trl5,
                trl6,
                trl7,
                trl8,
                trl9,
                trl10
              ]) ...[
                AppTCID(height: 40, trail: trl),
                10.w,
              ],
            ],
          ),
        ),
      );
    });
  }
}
