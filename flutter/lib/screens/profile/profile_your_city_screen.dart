// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trailcatch/utils/skeleton_utils.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/location_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/widget_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';
import 'package:trailcatch/widgets/textfield.dart';

class ProfileYourCityScreen extends StatefulWidget {
  const ProfileYourCityScreen({
    super.key,
  });

  @override
  State<ProfileYourCityScreen> createState() => _ProfileYourCityScreenState();
}

class _ProfileYourCityScreenState extends State<ProfileYourCityScreen> {
  late final TextEditingController _searchCtrl;

  late bool _loadingT;

  @override
  void initState() {
    _searchCtrl = TextEditingController();

    _loadingT = false;

    super.initState();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<LocationModel> locations = [];

    if (_searchCtrl.text.isNotEmpty && _searchCtrl.text.length >= 3) {
      locations = appVM.cities.where((location) {
        return location.city
            .toLowerCase()
            .contains(_searchCtrl.text.toLowerCase());
      }).toList();
    }

    return AppSimpleScaffold(
      title: 'Your City',
      loadingT: _loadingT,
      onBack: () async {
        if (_loadingT) return;

        AppRoute.goBack();
      },
      child: SizedBox(
        height: context.height - context.statusBar - AppTheme.appTitleHeight,
        width: context.width,
        child: Column(
          children: [
            if (appVM.yourCity != null) ...[
              Container(
                color: AppTheme.clBlack,
                child: AppWidgetButton(
                  onTap: () {
                    AppRoute.showPopup(
                      [
                        AppPopupAction(
                          appVM.yourCity!.city,
                          () async {
                            launchUrl(Uri.parse(
                              'https://www.google.com/search?q=${appVM.yourCity!.city}',
                            ));
                          },
                        ),
                        AppPopupAction(
                          '${appVM.yourCity!.country}, ${appVM.yourCity!.iso3.toUpperCase()}',
                          () async {
                            launchUrl(Uri.parse(
                              'https://www.google.com/search?q=${appVM.yourCity!.country}',
                            ));
                          },
                        ),
                      ],
                      bottoms: [
                        AppPopupAction(
                          'Unselect City',
                          color: AppTheme.clRed,
                          () async {
                            setState(() => _loadingT = true);

                            appVM.setYourCity(null);

                            await trailVM.reFetchRadar0();

                            trailVM.notify();
                            appVM.notify();

                            setState(() => _loadingT = false);
                          },
                        ),
                      ],
                    );
                  },
                  child: Container(
                    width: context.width,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
                    color: AppTheme.clBlack,
                    child: Column(
                      children: [
                        5.h,
                        Text(
                          'Selected City',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.clText05,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                appVM.yourCity!.city,
                                style: TextStyle(
                                  fontSize: 19,
                                  color: AppTheme.clText,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                                maxLines: 2,
                              ),
                            ),
                            20.w,
                            Text(
                              appVM.yourCity!.iso3.toUpperCase(),
                              style: TextStyle(
                                fontSize: 18,
                                color: AppTheme.clText,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            10.w,
                            Text(
                              '|',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.clText05,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            8.w,
                            Container(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.close_sharp,
                                size: 20,
                                color: AppTheme.clRed08,
                              ),
                            )
                          ],
                        ),
                        8.h,
                      ],
                    ),
                  ),
                ),
              ),
              5.h,
            ],
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    10.h,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.appLR,
                      ),
                      child: AppTextField(
                        title: 'Search',
                        placeholder: 'Enter city name',
                        ctrl: _searchCtrl,
                        autofocus: appVM.yourCity == null,
                        onChanged: (value) {
                          setState(() {});
                        },
                        onClear: () {
                          setState(() {
                            _searchCtrl.text = '';
                          });
                        },
                      ),
                    ),
                    10.h,
                    if (locations.isEmpty) ...[
                      fnCitySkeleton(context, true),
                      fnCitySkeleton(context, true),
                    ],
                    for (var location in locations)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.appLR),
                        child: Column(
                          children: [
                            AppWidgetButton(
                              onTap: () {
                                AppRoute.showPopup(
                                  [
                                    AppPopupAction(
                                      location.city,
                                      () async {
                                        launchUrl(Uri.parse(
                                          'https://www.google.com/search?q=${location.city}',
                                        ));
                                      },
                                    ),
                                    AppPopupAction(
                                      '${location.country}, ${location.iso3.toUpperCase()}',
                                      () async {
                                        launchUrl(Uri.parse(
                                          'https://www.google.com/search?q=${location.country}',
                                        ));
                                      },
                                    ),
                                  ],
                                  bottoms: [
                                    AppPopupAction(
                                      'Select City',
                                      color: AppTheme.clYellow,
                                      () async {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());

                                        setState(() => _loadingT = true);

                                        appVM.setYourCity(location);

                                        await trailVM.reFetchRadar0();

                                        trailVM.notify();
                                        appVM.notify();

                                        setState(() => _loadingT = false);
                                      },
                                    ),
                                  ],
                                );
                              },
                              child: Container(
                                width: context.width,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.appLR),
                                color: AppTheme.clBackground,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        location.city,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: location.city ==
                                                  appVM.yourCity?.city
                                              ? AppTheme.clYellow
                                              : AppTheme.clText,
                                        ),
                                        textAlign: TextAlign.left,
                                        maxLines: 2,
                                      ),
                                    ),
                                    20.w,
                                    Text(
                                      location.iso3.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: location.city ==
                                                appVM.yourCity?.city
                                            ? AppTheme.clYellow
                                            : AppTheme.clText,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (locations.indexOf(location) !=
                                locations.length - 1)
                              4.hrr(height: 2),
                          ],
                        ),
                      ),
                    (context.notch + 10).h,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
