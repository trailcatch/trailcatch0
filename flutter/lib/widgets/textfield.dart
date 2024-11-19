// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:trailcatch/theme.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.title = '',
    this.placeholder = '',
    required this.ctrl,
    this.error = '',
    this.onChanged,
    this.onFocus,
    this.onFocusLost,
    this.onClear,
    this.capitalization = false,
    this.autofocus = false,
  });

  final String title;
  final String placeholder;
  final TextEditingController ctrl;
  final String error;
  final Function(String value)? onChanged;
  final VoidCallback? onFocus;
  final VoidCallback? onFocusLost;
  final VoidCallback? onClear;
  final bool capitalization;
  final bool autofocus;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final GlobalKey _gkey;

  @override
  void initState() {
    _gkey = GlobalKey();

    widget.ctrl.value = TextEditingValue(
      text: widget.ctrl.text,
      selection: TextSelection.collapsed(offset: widget.ctrl.text.length),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _gkey,
      child: SizedBox(
        width: context.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.title.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.only(left: 3),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              4.h,
            ],
            SizedBox(
              height: AppTheme.appTextFieldHeight,
              child: Focus(
                onFocusChange: (bool value) {
                  (value ? widget.onFocus : widget.onFocusLost)?.call();
                },
                child: CupertinoTextField(
                  controller: widget.ctrl,
                  keyboardType: TextInputType.text,
                  keyboardAppearance: Brightness.dark,
                  autocorrect: false,
                  autofocus: widget.autofocus,
                  cursorColor: AppTheme.clText,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  textCapitalization: widget.capitalization
                      ? TextCapitalization.words
                      : TextCapitalization.none,
                  decoration: BoxDecoration(
                    color: AppTheme.clBlack,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppTheme.appBtnRadius),
                    ),
                    border: Border.all(
                      width: 1,
                      color: (widget.error.isNotEmpty)
                          ? AppTheme.clRed08
                          : AppTheme.clBlack,
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: AppTheme.ffUbuntuLight,
                    fontSize: 16,
                    letterSpacing: 0.2,
                    color: AppTheme.clText,
                  ),
                  placeholder: widget.placeholder,
                  placeholderStyle: const TextStyle(
                    fontFamily: AppTheme.ffUbuntuLight,
                    fontSize: 16,
                    letterSpacing: 0.2,
                    color: AppTheme.clText05,
                  ),
                  onChanged: widget.onChanged,
                  suffix: widget.onClear != null && widget.ctrl.text.isNotEmpty
                      ? AppGestureButton(
                          onTap: widget.onClear,
                          child: Container(
                            padding: const EdgeInsets.only(right: 8),
                            child: const Icon(
                              Icons.cancel_outlined,
                              color: AppTheme.clText04,
                              size: 18,
                            ),
                          ),
                        )
                      : Container(),
                ),
              ),
            ),
            if (widget.error.isNotEmpty) ...[
              4.h,
              Container(
                padding: const EdgeInsets.only(left: 3),
                child: Text(
                  widget.error,
                  style: const TextStyle(
                    color: AppTheme.clRed,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
