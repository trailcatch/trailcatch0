// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';

class AppAvatarImage extends StatelessWidget {
  const AppAvatarImage({
    super.key,
    this.size = 56,
    this.utcp,
    this.ageGroupStr,
    this.pictureFile,
    this.isDog = false,
    this.isInOurHearts = false,
  });

  final int size;
  final int? utcp;
  final String? ageGroupStr;
  final File? pictureFile;
  final bool isDog;
  final bool isInOurHearts;

  @override
  Widget build(BuildContext context) {
    late Widget wImage;

    final double radius = size >= 30 ? 8 : 6;

    if (pictureFile != null) {
      final FileStat stat = pictureFile!.statSync();

      late Widget wFile;
      if (DateTime.now().difference(stat.modified).inMinutes >= 5) {
        wFile = Image.file(
          pictureFile!,
          fit: BoxFit.cover,
        );
      } else {
        wFile = Image.memory(
          pictureFile!.readAsBytesSync(),
          fit: BoxFit.cover,
        );
      }

      wImage = ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: wFile,
      );
    } else {
      wImage = Container(
        width: size.toDouble(),
        height: size.toDouble(),
        decoration: BoxDecoration(
          color: AppTheme.clGrey900,
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
        child: Icon(
          Icons.person_outline,
          size: size / 2,
          color: AppTheme.clText03,
        ),
      );
    }

    String distStr = fnDistance(utcp ?? 0, fract: 0);
    distStr = fnNumCompact(int.tryParse(distStr) ?? 0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        color: utcp != null ? Colors.black : Colors.transparent,
      ),
      child: Column(
        children: [
          if (isInOurHearts)
            ColorFiltered(
              colorFilter: cstColorFilterGreyscale,
              child: SizedBox(
                width: size.toDouble(),
                height: size.toDouble(),
                child: wImage,
              ),
            )
          else
            SizedBox(
              width: size.toDouble(),
              height: size.toDouble(),
              child: wImage,
            ),
          if (ageGroupStr != null) ...[
            1.h,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ageGroupStr!,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            1.h,
          ] else if (utcp != null) ...[
            1.h,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  distStr,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                3.w,
                Text(
                  fnDistUnit(),
                  style: const TextStyle(
                    fontSize: 8,
                  ),
                ),
              ],
            ),
            1.h,
          ] else if (isDog) ...[
            1.h,
            Text(
              isInOurHearts ? 'Beyond' : 'Dog',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            1.h,
          ]
        ],
      ),
    );
  }
}
