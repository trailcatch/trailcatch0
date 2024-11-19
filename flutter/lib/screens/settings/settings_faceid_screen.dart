// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/buttons/field_button.dart';
import 'package:trailcatch/widgets/buttons/widget_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

class SettingsFaceIdScreen extends StatefulWidget {
  const SettingsFaceIdScreen({super.key});

  @override
  State<SettingsFaceIdScreen> createState() => _SettingsFaceIdScreenState();
}

class _SettingsFaceIdScreenState extends State<SettingsFaceIdScreen> {
  bool _isSupported = true;
  bool _loading = false;

  @override
  void initState() {
    fnIsFaceIdSupported().then((value) {
      if (_isSupported != value) {
        if (mounted) {
          setState(() {
            _isSupported = value;
          });
        }
      }
    });

    super.initState();
  }

  Future<void> _updateUserFaceId() async {
    await fnTry(() async {
      await userServ.fnUsersUpdate(faceid: appVM.settings.faceid);
      appVM.notify();
    });
  }

  Future<bool> _validate() async {
    if ((await fnIsFaceIdSupported())) {
      return await AppRoute.goTo('/pin', args: {
        'canGoBack': true,
        'showPinDesc': false,
      });
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AppSimpleScaffold(
      title: 'Face ID & Passcode',
      loading: _loading,
      actions: [
        if (!_isSupported)
          AppWidgetButton(
            onTap: () async {
              setState(() => _loading = true);
              await Future.delayed(1000.mlsec);

              bool isOk = await fnIsFaceIdSupported();
              if (!isOk) {
                setState(() => _loading = false);

                throw AppError(
                  message: 'Failed to use Face ID or Passcode.',
                  code: AppErrorCode.faceId,
                );
              } else {
                setState(() {
                  _loading = false;
                  _isSupported = true;
                });
              }
            },
            child: const Icon(
              Icons.lock_reset_rounded,
              color: AppTheme.clText,
              size: 26,
            ),
          ),
      ],
      children: [
        10.h,
        Opacity(
          opacity: _isSupported ? 1.0 : 0.3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
            child: AppFieldButton(
              title: 'How often to ask',
              placeholder: '',
              text: !_isSupported
                  ? 'Not Supported'
                  : appVM.settings.faceid == 0
                      ? 'Always Require'
                      : (appVM.settings.faceid == -1
                          ? 'Never'
                          : 'Require After ${appVM.settings.faceid} Minutes'),
              down: true,
              onTap: () {
                if (!_isSupported) return;

                AppRoute.showPopup(
                  [
                    AppPopupAction(
                      'Never',
                      selected: appVM.settings.faceid == -1,
                      () async {
                        if (!(await _validate())) return;

                        setState(() {
                          appVM.settings.faceid = -1;
                        });

                        _updateUserFaceId();
                      },
                    ),
                    AppPopupAction(
                      'Always Require',
                      selected: appVM.settings.faceid == 0,
                      () async {
                        if (!(await _validate())) return;

                        setState(() {
                          appVM.settings.faceid = 0;
                        });

                        _updateUserFaceId();
                      },
                    ),
                    AppPopupAction(
                      'Require After 15 Minutes',
                      selected: appVM.settings.faceid == 15,
                      () async {
                        if (!(await _validate())) return;

                        setState(() {
                          appVM.settings.faceid = 15;
                        });

                        _updateUserFaceId();
                      },
                    ),
                    AppPopupAction(
                      'Require After 30 Minutes',
                      selected: appVM.settings.faceid == 30,
                      () async {
                        setState(() {
                          appVM.settings.faceid = 30;
                        });

                        _updateUserFaceId();
                      },
                    ),
                    AppPopupAction(
                      'Require After 60 Minutes',
                      selected: appVM.settings.faceid == 60,
                      () async {
                        if (!(await _validate())) return;

                        setState(() {
                          appVM.settings.faceid = 60;
                        });

                        _updateUserFaceId();
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
