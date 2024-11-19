// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

abstract class BaseViewModel extends ChangeNotifier {
  void notify() => notifyListeners();
  void close() {}

  @override
  // ignore: must_call_super
  void dispose() {}
}
