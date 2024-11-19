// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';

import 'package:trailcatch/screens/about/about_screen.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class Error404ContactsSheet extends StatelessWidget {
  const Error404ContactsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBottomScaffold(
      title: 'Support',
      child: AboutSupport(),
    );
  }
}
