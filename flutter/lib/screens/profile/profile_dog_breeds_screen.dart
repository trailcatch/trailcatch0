// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trailcatch/getit.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/buttons/option_button.dart';
import 'package:trailcatch/widgets/progress_indicator.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/widget_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';
import 'package:trailcatch/widgets/textfield.dart';

class ProfileDogsBreedScreen extends StatefulWidget {
  const ProfileDogsBreedScreen({
    super.key,
    this.dogsBreed,
    this.multiSelect,
    this.justView,
  });

  final List<int>? dogsBreed;
  final bool? multiSelect;
  final bool? justView;

  @override
  State<ProfileDogsBreedScreen> createState() => _ProfileDogsBreedScreenState();
}

class _ProfileDogsBreedScreenState extends State<ProfileDogsBreedScreen> {
  late final ScrollController _ctrl;

  late final TextEditingController _dogsCtrl;
  late List<int> _dogsBreed;

  late bool _multiSelect;
  late bool _showSelected;
  late bool _justView;

  late bool _isChanged;

  late bool _loading;
  late bool _gridMode;

  @override
  void initState() {
    _ctrl = ScrollController();

    _dogsCtrl = TextEditingController();
    _dogsBreed = List<int>.from(widget.dogsBreed ?? []);

    _multiSelect = widget.multiSelect ?? false;
    _showSelected = false;
    _justView = widget.justView ?? false;

    _isChanged = false;
    _gridMode = true;

    if (appVM.wikiDogsData.isEmpty) {
      _loading = true;
      scheduleMicrotask(_loadDogsData);
    } else {
      _loading = false;
    }

    super.initState();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _dogsCtrl.dispose();

    super.dispose();
  }

  Future<void> _loadDogsData() async {
    try {
      appVM.wikiDogsData = List<Map<String, dynamic>>.from(jsonDecode(
        await rootBundle.loadString(
          'assets/***/dogs_data.json',
        ),
      ));
    } catch (_) {}

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  void _onSelect(Map<String, dynamic> wikiDog) {
    if (_multiSelect) {
      setState(() {
        if (_dogsBreed.contains(wikiDog['id'])) {
          _dogsBreed.remove(wikiDog['id']);
        } else {
          _dogsBreed.add(wikiDog['id']);
        }

        _dogsBreed.sort();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 250), () {
        AppRoute.goBack([wikiDog['id']]);
      });
    }
  }

  void _onTap(Map<String, dynamic> wikiDog) {
    AppRoute.showPopup(
      [
        AppPopupAction(
          'Open Wikipedia',
          () async {
            if ((wikiDog['link'] as String).isNotEmpty) {
              launchUrl(
                Uri.parse(
                  'https://en.wikipedia.org/wiki/${wikiDog['link']}',
                ),
              );
            }
          },
        ),
        AppPopupAction(
          'Read More',
          () async {
            if ((wikiDog['name'] as String).isNotEmpty) {
              launchUrl(
                Uri.parse(
                  'https://www.google.com/search?q=dog+breed+${wikiDog['name']}',
                ),
              );
            }
          },
        ),
      ],
      bottoms: [
        if (!_justView)
          AppPopupAction(
            !_dogsBreed.contains(wikiDog['id']) ? 'Select' : 'Unselect',
            color: !_dogsBreed.contains(wikiDog['id'])
                ? AppTheme.clYellow
                : AppTheme.clRed,
            () async {
              _onSelect(wikiDog);
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    late List<Map<String, dynamic>> wikiDogs;
    if (_dogsCtrl.text.isNotEmpty) {
      wikiDogs = appVM.wikiDogsData.where((wikiDog) {
        return (wikiDog['name'] as String)
            .toLowerCase()
            .contains(_dogsCtrl.text.toLowerCase());
      }).toList();
    } else {
      wikiDogs = appVM.wikiDogsData;
    }

    if (_showSelected) {
      wikiDogs = wikiDogs.where((wkdg) {
        return _dogsBreed.contains(wkdg['id']);
      }).toList();
    }

    _isChanged = !listEquals(_dogsBreed, widget.dogsBreed);

    return AppSimpleScaffold(
      title: 'Dog Breeds',
      loading: _loading,
      onBack: () async {
        _dogsBreed.sort();
        AppRoute.goBack(_multiSelect ? _dogsBreed : null);
      },
      actions: [
        if (_multiSelect)
          AppWidgetButton(
            onTap: () {
              if (!_isChanged) return;

              AppRoute.goBack(_dogsBreed);
            },
            child: Icon(
              Icons.done_all,
              size: 28,
              color: _isChanged ? AppTheme.clYellow : AppTheme.clText03,
            ),
          ),
        AppWidgetButton(
          onTap: () {
            setState(() {
              _gridMode = !_gridMode;
            });
          },
          child: Icon(
            Icons.grid_view_outlined,
            color: _gridMode ? AppTheme.clYellow : AppTheme.clText,
            size: 26,
          ),
        ),
      ],
      child: SizedBox(
        width: context.width,
        height: context.height - AppTheme.appTitleHeight - context.statusBar,
        child: Column(
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
                  value: _showSelected ? 'Selected' : 'The World of Dogs',
                  opts: const ['The World of Dogs', 'Selected'],
                  textColor: AppTheme.clText07,
                  onValueChanged: (value) async {
                    if (value == 'The World of Dogs' && _showSelected) {
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
                placeholder: 'Search dog breed',
                ctrl: _dogsCtrl,
                onChanged: (value) {
                  setState(() {});
                },
                onClear: () {
                  setState(() {
                    _dogsCtrl.text = '';
                  });
                },
              ),
            ),
            10.h,
            if (wikiDogs.isEmpty)
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 5),
                child: const Text(
                  'No selected dog breeds',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.clText05,
                  ),
                ),
              ),
            5.h,
            if (wikiDogs.isNotEmpty) 0.hrr(height: 2),
            if (_gridMode)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.appLR,
                  ),
                  child: GridView.count(
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: context.notch + 10,
                    ),
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 6,
                    children: [
                      for (var wikiDog in wikiDogs)
                        AppGestureButton(
                          onTap: () {
                            AppRoute.goSheetTo(
                              '/profile_dog_breed_card',
                              args: {
                                'wikiDog': wikiDog,
                                'selected': _dogsBreed.contains(wikiDog['id']),
                                'onSelect': _justView
                                    ? null
                                    : (wikiDog) {
                                        AppRoute.goSheetBack();
                                        _onSelect(wikiDog);
                                      },
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                border: Border.all(
                                    width: 2,
                                    color: _dogsBreed.contains(wikiDog['id'])
                                        ? AppTheme.clYellow
                                        : AppTheme.clBackground)),
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              child: Image.network(
                                wikiDog['picture'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: const Text(
                                      'Image not found.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.clText05,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                                loadingBuilder: (
                                  BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;

                                  return const SizedBox(
                                    height: 100,
                                    child:
                                        Center(child: AppProgressIndicator()),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            if (!_gridMode)
              Expanded(
                child: ListView.builder(
                    controller: _ctrl,
                    itemCount: wikiDogs.length,
                    itemBuilder: (context, index) {
                      final wikiDog = wikiDogs[index];
                      return Column(
                        children: [
                          AppWidgetButton(
                            onTap: () => _onTap(wikiDog),
                            child: DogCard(
                              wikiDog: wikiDog,
                              selected: _dogsBreed.contains(wikiDog['id']),
                            ),
                          ),
                          0.hrr(height: 3),
                        ],
                      );
                    }),
              ),
          ],
        ),
      ),
    );
  }
}

class DogCard extends StatelessWidget {
  const DogCard({
    super.key,
    required this.wikiDog,
    required this.selected,
  });

  final Map<String, dynamic> wikiDog;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        10.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          alignment: Alignment.centerLeft,
          color: AppTheme.clBackground,
          child: Text(
            wikiDog['name'],
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: selected ? AppTheme.clYellow : AppTheme.clText,
            ),
          ),
        ),
        10.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
          child: 0.hrr(color: AppTheme.clText02, height: 0.5),
        ),
        15.h,
        if ((wikiDog['picture'] as String).isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
            child: Container(
              width: context.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(
                  width: 2,
                  color: selected ? AppTheme.clYellow : AppTheme.clTransparent,
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: Image.network(
                  wikiDog['picture'],
                  errorBuilder: (context, error, stackTrace) => Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Image not found.',
                      style: TextStyle(
                        color: AppTheme.clText05,
                      ),
                    ),
                  ),
                  loadingBuilder: (
                    BuildContext context,
                    Widget child,
                    ImageChunkEvent? loadingProgress,
                  ) {
                    if (loadingProgress == null) return child;

                    return const SizedBox(
                      height: 100,
                      child: Center(child: AppProgressIndicator()),
                    );
                  },
                ),
              ),
            ),
          ),
          10.h,
        ],
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.appLR,
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            wikiDog['desc'],
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.clText08,
              height: 1.4,
            ),
          ),
        ),
        25.h,
      ],
    );
  }
}
