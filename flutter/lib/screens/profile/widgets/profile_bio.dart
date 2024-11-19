// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';

class ProfileBio extends StatelessWidget {
  const ProfileBio({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final String contactsStr = UserContact.formatToStr(user.contacts);
    final String countryStr = fnCountryNameByIso3(user.uiso3);
    final String ageGroupStr = fnAgeGroup(gender: user.gender, age: user.age);

    return Container(
      width: context.width,
      padding: const EdgeInsets.only(
        left: AppTheme.appLR,
        right: AppTheme.appLR,
        top: 0,
        bottom: 10,
      ),
      color: AppTheme.clBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (user.withDogs)
            SizedBox(
              width: context.width * 0.75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Dog${user.dogs.length > 1 ? 's' : ''}:',
                    style: const TextStyle(fontSize: 12),
                  ),
                  4.w,
                  Expanded(
                    child: Text(
                      user.dogs.map((dog) => dog.name).join(', '),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          if (ageGroupStr.isNotEmpty) ...[
            2.h,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Age Group:',
                  style: TextStyle(fontSize: 12),
                ),
                4.w,
                Text(
                  ageGroupStr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          if (countryStr.isNotEmpty) ...[
            2.h,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Nationality:',
                  style: TextStyle(fontSize: 12),
                ),
                4.w,
                Text(
                  countryStr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          if (contactsStr.isNotEmpty) ...[
            2.h,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Contacts:',
                  style: TextStyle(fontSize: 12),
                ),
                4.w,
                Expanded(
                  child: Text(
                    contactsStr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
