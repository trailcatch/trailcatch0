// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class AboutLusiSheet extends StatelessWidget {
  const AboutLusiSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBottomScaffold(
      title: 'Lusi',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            10.h,
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.appLR * 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Transform.rotate(
                    angle: 0.25,
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: Image.asset(
                          'assets/***/luuuusi1.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: -0.1,
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: Image.asset(
                          'assets/***/luuuusi2.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: 0.4,
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: Image.asset(
                          'assets/***/luuuusi3.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            20.h,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.appLR,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppTheme.clBlack,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lusi is more than just a wonderful dog - she\'s a best friend who has shared countless moments with me over the years.',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  8.h,
                  Text(
                    'Her energy is boundless, and when she runs, it\'s like pure joy radiates from every paw hitting the ground.',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  8.h,
                  Text(
                    'Together, we\'ve raced through so many memories, and I know we\'ll keep running forward, side by side, chasing adventures and happiness with all our hearts.',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  20.h,
                  Text(
                    'Thank you, Lusi.',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
