// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/screens/profile/profile_dog_breeds_screen.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileDogBreedCardSheet extends StatelessWidget {
  const ProfileDogBreedCardSheet({
    super.key,
    required this.wikiDog,
    required this.selected,
    required this.onSelect,
  });

  final Map<String, dynamic> wikiDog;
  final bool selected;
  final Function(Map<String, dynamic> wikiDog)? onSelect;

  @override
  Widget build(BuildContext context) {
    return AppBottomScaffold(
      title: 'Dog Card',
      padTop: 0,
      padBottom: 0,
      child: SizedBox(
        height: context.height * 0.72,
        width: context.width,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DogCard(
                wikiDog: wikiDog,
                selected: selected,
              ),
              20.h,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.appLR,
                ),
                child: Column(
                  children: [
                    AppSimpleButton(
                      width: context.width * AppTheme.appBtnWidth,
                      onTry: () async {
                        if ((wikiDog['link'] as String).isNotEmpty) {
                          launchUrl(
                            Uri.parse(
                              'https://en.wikipedia.org/wiki/${wikiDog['link']}',
                            ),
                          );
                        }
                      },
                      text: 'Open Wikipedia',
                    ),
                    AppSimpleButton(
                      width: context.width * AppTheme.appBtnWidth,
                      onTry: () async {
                        if ((wikiDog['name'] as String).isNotEmpty) {
                          launchUrl(
                            Uri.parse(
                              'https://www.google.com/search?q=dog+breed+${wikiDog['name']}',
                            ),
                          );
                        }
                      },
                      text: 'Read More',
                    ),
                    if (onSelect != null) ...[
                      15.h,
                      AppSimpleButton(
                        width: context.width * AppTheme.appBtnWidth,
                        onTap: () => onSelect!(wikiDog),
                        textColor:
                            selected ? AppTheme.clRed : AppTheme.clYellow,
                        borderColor:
                            selected ? AppTheme.clRed : AppTheme.clYellow,
                        text: selected ? 'Unselect' : 'Select',
                      ),
                    ],
                  ],
                ),
              ),
              (context.notch + 10).h,
            ],
          ),
        ),
      ),
    );
  }
}
