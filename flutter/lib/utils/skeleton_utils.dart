// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/theme.dart';

Widget fnTrailSkeleton(BuildContext context, [bool empty = false]) {
  return Container(
    color: AppTheme.clBackground,
    padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
    child: Column(
      children: [
        10.h,
        Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: !empty ? AppTheme.clText005 : AppTheme.clText01,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
                color: empty ? null : AppTheme.clText005,
              ),
            ),
            10.w,
            Expanded(
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: !empty ? AppTheme.clText005 : AppTheme.clText01,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  color: empty ? null : AppTheme.clText005,
                ),
              ),
            ),
          ],
        ),
        10.h,
        Container(
          height: 120,
          width: context.width,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: !empty ? AppTheme.clText005 : AppTheme.clText01,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
            color: empty ? null : AppTheme.clText005,
          ),
        )
      ],
    ),
  );
}

Widget fnTrailGridSkeletons(BuildContext context, [bool empty = false]) {
  return Container(
    color: AppTheme.clBackground,
    padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
    child: Column(
      children: [
        10.h,
        Container(
          height: 20,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: !empty ? AppTheme.clText005 : AppTheme.clText01,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(4),
            ),
            color: empty ? null : AppTheme.clText005,
          ),
        ),
        15.h,
        Row(
          children: [
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: !empty ? AppTheme.clText005 : AppTheme.clText01,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  color: empty ? null : AppTheme.clText005,
                ),
              ),
            ),
            15.w,
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: !empty ? AppTheme.clText005 : AppTheme.clText01,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  color: empty ? null : AppTheme.clText005,
                ),
              ),
            ),
            15.w,
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: !empty ? AppTheme.clText005 : AppTheme.clText01,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  color: empty ? null : AppTheme.clText005,
                ),
              ),
            ),
            15.w,
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: !empty ? AppTheme.clText005 : AppTheme.clText01,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  color: empty ? null : AppTheme.clText005,
                ),
              ),
            ),
          ],
        ),
        15.h,
        Row(
          children: [
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: !empty ? AppTheme.clText005 : AppTheme.clText01,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  color: empty ? null : AppTheme.clText005,
                ),
              ),
            ),
            15.w,
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: !empty ? AppTheme.clText005 : AppTheme.clText01,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  color: empty ? null : AppTheme.clText005,
                ),
              ),
            ),
            15.w,
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: !empty ? AppTheme.clText005 : AppTheme.clText01,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  color: empty ? null : AppTheme.clText005,
                ),
              ),
            ),
            15.w,
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: !empty ? AppTheme.clText005 : AppTheme.clText01,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  color: empty ? null : AppTheme.clText005,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget fnUserSkeleton(BuildContext context, [bool empty = false]) {
  return Container(
    color: AppTheme.clBackground,
    padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
    width: context.width,
    height: 120,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 70,
          width: 60,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: !empty ? AppTheme.clText005 : AppTheme.clText01,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
            color: empty ? null : AppTheme.clText005,
          ),
        ),
        10.w,
        Expanded(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: !empty ? AppTheme.clText005 : AppTheme.clText01,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
              color: empty ? null : AppTheme.clText005,
            ),
          ),
        ),
        10.w,
        Container(
          height: 120,
          width: 80,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: !empty ? AppTheme.clText005 : AppTheme.clText01,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
            color: empty ? null : AppTheme.clText005,
          ),
        ),
      ],
    ),
  );
}

Widget fnNotifSkeleton(BuildContext context, [bool empty = false]) {
  return Container(
    color: AppTheme.clBackground,
    padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
    child: Column(
      children: [
        10.h,
        Container(
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: !empty ? AppTheme.clText005 : AppTheme.clText01,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
            color: empty ? null : AppTheme.clText005,
          ),
        ),
        10.h,
        Row(
          children: [
            Expanded(
              child: Container(
                height: 142,
                width: 42,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: !empty ? AppTheme.clText005 : AppTheme.clText01,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  color: empty ? null : AppTheme.clText005,
                ),
              ),
            ),
            10.w,
            Expanded(
              child: Container(
                height: 142,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: !empty ? AppTheme.clText005 : AppTheme.clText01,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  color: empty ? null : AppTheme.clText005,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget fnCitySkeleton(BuildContext context, [bool empty = false]) {
  return Container(
    color: AppTheme.clBackground,
    padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
    child: Column(
      children: [
        10.h,
        Row(
          children: [
            Expanded(
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: !empty ? AppTheme.clText005 : AppTheme.clText01,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  color: empty ? null : AppTheme.clText005,
                ),
              ),
            ),
            10.w,
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: !empty ? AppTheme.clText005 : AppTheme.clText01,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
                color: empty ? null : AppTheme.clText005,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
