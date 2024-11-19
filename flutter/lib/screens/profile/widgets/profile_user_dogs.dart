// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trailcatch/getit.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/avatar_image.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';

class ProfileUserAndDogs extends StatelessWidget {
  const ProfileUserAndDogs({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      height: 90,
      color: AppTheme.clBackground,
      child: PageView(
        controller: PageController(
          viewportFraction: 0.925,
        ),
        children: [
          Container(
            color: AppTheme.clBackground,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 12, bottom: 6),
                  child: AppAvatarImage(
                    utcp: user.utcp,
                    pictureFile: user.cachePictureFile,
                  ),
                ),
                14.w,
                Container(height: 90, width: 3, color: AppTheme.clBlack),
                12.w,
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: AppTheme.clBackground,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              6.h,
                              Text(
                                user.fullName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '@${user.username}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.clText08,
                                  height: 1,
                                ),
                              ),
                              10.h,
                            ],
                          ),
                        ),
                      ),
                      if (user.dogs0.isNotEmpty) ...[
                        15.w,
                        Container(
                          height: 90,
                          width: 3,
                          color: AppTheme.clBlack,
                        ),
                        10.w,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (var dog in user.dogs0)
            Builder(builder: (context) {
              String bioStr = '${UserGender.format(dog.gender)},';

              if (dog.inOurHeartsDateAt != null) {
                bioStr += ' at';
              }

              bioStr +=
                  ' ${dog.age == 0 ? '0+' : dog.age} year${dog.age > 1 ? 's' : ''}';

              if (dog.inOurHeartsDateAt != null) {
                bioStr += ' old';
              }

              return Container(
                color: AppTheme.clBackground,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 8, bottom: 6),
                      child: SizedBox(
                        height: 72,
                        child: AppAvatarImage(
                          pictureFile: dog.cachePictureFile,
                          isDog: true,
                          isInOurHearts: dog.inOurHeartsDateAt != null,
                        ),
                      ),
                    ),
                    14.w,
                    Container(height: 90, width: 3, color: AppTheme.clBlack),
                    12.w,
                    Expanded(
                      child: AppGestureButton(
                        onTry: () async {
                          String url = fnDogBreedLinkById(dog.breedId);
                          if (url.isNotEmpty) {
                            launchUrl(Uri.parse(url));
                          } else if (dog.breedCustomName.isNotEmpty) {
                            launchUrl(Uri.parse(
                              'https://www.google.com/search?q=dog+breed+${dog.breedCustomName}',
                            ));
                          }
                        },
                        child: Container(
                          color: AppTheme.clBackground,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      dog.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    2.h,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Breed:',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        4.w,
                                        Container(
                                          color: AppTheme.clBackground,
                                          child: Row(
                                            children: [
                                              Text(
                                                dog.breedCustomName.isNotEmpty
                                                    ? dog.breedCustomName
                                                    : fnDogBreedNameById(
                                                        dog.breedId),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              6.w,
                                              Container(
                                                padding: const EdgeInsets.only(
                                                  top: 2,
                                                ),
                                                child: const Icon(
                                                  Icons.link,
                                                  color: AppTheme.clYellow,
                                                  size: 20,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Bio:',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        4.w,
                                        Text(
                                          bioStr,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (user.dogs0.indexOf(dog) !=
                                  user.dogs0.length - 1) ...[
                                15.w,
                                Container(
                                  height: 90,
                                  width: 3,
                                  color: AppTheme.clBlack,
                                ),
                                10.w,
                              ] else
                                10.w,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
