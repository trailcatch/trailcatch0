// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/option_button.dart';
import 'package:trailcatch/widgets/buttons/widget_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';
import 'package:trailcatch/widgets/textfield.dart';

class ProfileCountriesScreen extends StatefulWidget {
  const ProfileCountriesScreen({
    super.key,
    required this.uiso3s,
    this.multiSelect,
  });

  final List<String> uiso3s;
  final bool? multiSelect;

  @override
  State<ProfileCountriesScreen> createState() => _ProfileCountriesScreenState();
}

class _ProfileCountriesScreenState extends State<ProfileCountriesScreen> {
  late final TextEditingController _countryCtrl;
  late List<String> _uiso3s;

  late bool _multiSelect;
  late bool _showSelected;

  late bool _isChanged;

  @override
  void initState() {
    _countryCtrl = TextEditingController();

    widget.uiso3s.sort();
    _uiso3s = List<String>.from(widget.uiso3s);
    _uiso3s.sort();

    _multiSelect = widget.multiSelect ?? false;
    _showSelected = false;

    _isChanged = false;

    super.initState();
  }

  @override
  void dispose() {
    _countryCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late List<Map<String, dynamic>> countries;
    if (_countryCtrl.text.isNotEmpty) {
      countries = appVM.countries.where((country) {
        final bool isName = (country['name'] as String)
            .toLowerCase()
            .contains(_countryCtrl.text.toLowerCase());
        final bool isIso3 = (country['iso3'] as String)
            .toLowerCase()
            .contains(_countryCtrl.text.toLowerCase());

        return isName || isIso3;
      }).toList();
    } else {
      countries = appVM.countries;
    }

    if (_showSelected) {
      countries = countries.where((ctrl) {
        return _uiso3s.contains(ctrl['iso3']);
      }).toList();
    }

    _isChanged = !listEquals(_uiso3s, widget.uiso3s);

    return AppSimpleScaffold(
      title: 'Countries',
      actions: [
        if (_multiSelect)
          AppWidgetButton(
            onTap: () {
              if (!_isChanged) return;

              AppRoute.goBack(_uiso3s);
            },
            child: Icon(
              Icons.done_all,
              size: 28,
              color: _isChanged ? AppTheme.clYellow : AppTheme.clText03,
            ),
          ),
      ],
      children: [
        if (_multiSelect)
          Container(
            color: AppTheme.clBlack,
            padding: const EdgeInsets.only(
              left: AppTheme.appLR,
              right: AppTheme.appLR,
              top: 1,
              bottom: 3,
            ),
            child: AppOptionButton(
              value: _showSelected ? 'Selected' : 'The World',
              opts: const ['The World', 'Selected'],
              textColor: AppTheme.clText07,
              onValueChanged: (value) async {
                if (value == 'The World' && _showSelected) {
                  setState(() {
                    _showSelected = false;
                  });
                } else if (value == 'Selected' && !_showSelected) {
                  setState(() {
                    _showSelected = true;
                  });
                }
              },
            ),
          ),
        10.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: AppTextField(
            title: 'Search',
            placeholder: 'Enter country name or code',
            ctrl: _countryCtrl,
            onChanged: (value) {
              setState(() {});
            },
            onClear: () {
              setState(() {
                _countryCtrl.text = '';
              });
            },
          ),
        ),
        10.h,
        if (countries.isEmpty)
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 5),
            child: const Text(
              'No selected countries',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.clText05,
              ),
            ),
          ),
        for (var country in countries)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
            child: Column(
              children: [
                AppWidgetButton(
                  onTap: () {
                    if (_multiSelect) {
                      setState(() {
                        if (_uiso3s.contains(country['iso3'])) {
                          _uiso3s.remove(country['iso3']);
                        } else {
                          _uiso3s.add(country['iso3']);
                        }

                        _uiso3s.sort();
                      });
                    } else {
                      AppRoute.goBack([country['iso3']]);
                    }
                  },
                  child: Container(
                    width: context.width,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
                    color: AppTheme.clBackground,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            country['name'],
                            style: TextStyle(
                              fontSize: 18,
                              color: _uiso3s.contains(country['iso3'])
                                  ? AppTheme.clYellow
                                  : AppTheme.clText,
                            ),
                            textAlign: TextAlign.left,
                            maxLines: 2,
                          ),
                        ),
                        20.w,
                        Text(
                          country['iso3'].toUpperCase(),
                          style: TextStyle(
                            fontSize: 18,
                            color: _uiso3s.contains(country['iso3'])
                                ? AppTheme.clYellow
                                : AppTheme.clText,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ),
                if (countries.indexOf(country) != countries.length - 1)
                  4.hrr(height: 2),
              ],
            ),
          ),
      ],
    );
  }
}
