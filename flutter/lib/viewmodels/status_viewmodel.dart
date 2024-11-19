// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';

import 'package:trailcatch/logger.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/viewmodels/base_viewmodel.dart';

class StatusViewModel extends BaseViewModel {
  String statusMsg = '';
  VoidCallback? statusMsgOnTap;

  //+ connection

  bool _online = true;
  bool get isOnline => _online;

  void setOnline(bool value) {
    if (_online == value) return;

    _online = value;

    if (!value) {
      addError(AppError(
        message: 'Offline. No internet connection.',
        code: AppErrorCode.offline,
      ));
    } else if (value) {
      clearError();
    }

    notify();
  }

  Future<void> reOnline() async {
    setOnline(await fnIsOnline());
  }

  //+ errors

  AppError? _error;
  AppError? get error => _error;

  bool get isError => _error != null;

  void addError(AppError error, {bool ioerr = true}) {
    _error = error;
    notify();

    if (ioerr) {
      logger.e(
        error.toString(),
        error: error.error,
        stackTrace: error.stack,
      );
    }
  }

  Future<void> unwrap() async {
    if (_error != null) {
      await AppRoute.goSheetTo('/status');
    }
  }

  void clearError({bool silence = false}) {
    if (_error != null) {
      _error = null;
      if (!silence) notify();
    }
  }
}
