// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/progress_indicator.dart';
import 'package:trailcatch/widgets/status.dart';

class AppSimpleScaffold extends StatelessWidget {
  const AppSimpleScaffold({
    super.key,
    this.child,
    this.children,
    this.title,
    this.loading = false,
    this.loadingT = false,
    this.loadingTop = false,
    this.loadingBottom = false,
    this.loadingExt = false,
    this.actions,
    this.hideBack = false,
    this.onBack,
    this.onTapTitle,
    this.physics,
    this.wBottom,
    this.scrollCtrl,
    this.padding,
    this.onRefresh,
    this.onLoadMore,
    this.loadMoreAnimate = false,
  });

  final Widget? child;
  final List<Widget>? children;
  final String? title;
  final List<Widget>? actions;
  final bool loading;
  final bool loadingT;
  final bool loadingTop;
  final bool loadingBottom;
  final bool loadingExt;
  final bool hideBack;
  final Future<void> Function()? onBack;
  final VoidCallback? onTapTitle;
  final ScrollPhysics? physics;
  final Widget? wBottom;
  final ScrollController? scrollCtrl;
  final EdgeInsets? padding;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoadMore;
  final bool loadMoreAnimate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: key,
        backgroundColor: AppTheme.clBackground,
        resizeToAvoidBottomInset: false,
        appBar: title != null
            ? AppBar(
                elevation: 0,
                automaticallyImplyLeading: false,
                scrolledUnderElevation: 0,
                backgroundColor: AppTheme.clBackground,
                toolbarHeight: AppTheme.appTitleHeight,
                shadowColor: AppTheme.clBackground,
                foregroundColor: AppTheme.clBackground,
                surfaceTintColor: AppTheme.clBackground,
                leading: hideBack
                    ? null
                    : AppGestureButton(
                        onTry: onBack ?? AppRoute.goBack,
                        child: const Icon(
                          Icons.close_rounded,
                          size: 30,
                          color: AppTheme.clText,
                        ),
                      ),
                actions: [
                  ...?actions,
                  6.w,
                ],
                titleSpacing: 0,
                centerTitle: false,
                title: Container(
                  padding: EdgeInsets.only(left: hideBack ? 16 : 6),
                  child: GestureDetector(
                    onTap: onTapTitle,
                    child: Row(
                      children: [
                        Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (onTapTitle != null) ...[
                          2.w,
                          Container(
                            padding: const EdgeInsets.only(top: 4),
                            child: Icon(
                              Icons.keyboard_arrow_down_outlined,
                              color: trailVM.trailFilters.isEmpty
                                  ? AppTheme.clText
                                  : AppTheme.clYellow,
                              size: 20,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            : null,
        body: Stack(
          children: [
            SizedBox(
              width: context.width,
              height: context.height,
              child: Container(
                padding: EdgeInsets.only(bottom: context.keyboardHeight),
                child: Column(
                  children: [
                    if (physics is AlwaysScrollableScrollPhysics && loadingTop)
                      const ScaffoldLineIndicator()
                    else
                      Container(
                          height: 1.5,
                          color:
                              loadingT ? AppTheme.clYellow : AppTheme.clBlack),
                    if (title?.contains('404') == false) const AppStatus(),
                    Expanded(
                      child: Container(
                        color: AppTheme.clBackground,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (physics is AlwaysScrollableScrollPhysics)
                              ScaffoldTopIconIndicator(
                                ctrl: scrollCtrl,
                                onRefresh: onRefresh,
                              ),
                            if (physics is AlwaysScrollableScrollPhysics)
                              ScaffoldBottomIconIndicator(
                                ctrl: scrollCtrl,
                                onLoadMore: onLoadMore,
                                hideBack: hideBack,
                                animate: loadMoreAnimate,
                              ),
                            SingleChildScrollView(
                              physics: physics ?? const ClampingScrollPhysics(),
                              controller: scrollCtrl,
                              child: Container(
                                padding: padding,
                                child: Column(
                                  children: [
                                    if (physics == null ||
                                        physics is ClampingScrollPhysics)
                                      0.hrr(height: 1.5),
                                    if (child != null) child! else ...?children,
                                    if (hideBack)
                                      (AppTheme.appNavHeight).h
                                    else if (physics == null ||
                                        physics is ClampingScrollPhysics)
                                      (context.notch + 10).h
                                    else
                                      (AppTheme.appNavHeight).h
                                  ],
                                ),
                              ),
                            ),
                            if (physics is AlwaysScrollableScrollPhysics)
                              Container(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (loadingBottom)
                                      const ScaffoldLineIndicator()
                                    else
                                      0.hrr(height: 1.5),
                                    if (hideBack) (AppTheme.appNavHeight).h,
                                  ],
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                    if (wBottom != null) ...[
                      wBottom!,
                      if (hideBack) (AppTheme.appNavHeight).h,
                      (context.notch + 10).h,
                    ],
                  ],
                ),
              ),
            ),
            if (loading) const AppProgressIndicatorCenter(),
            if (loadingTop || loadingBottom) const AppProgressIndicatoEmpty(),
            if (loadingExt)
              Container(
                width: context.width,
                height: context.height,
                color: AppTheme.clBackground09,
                child: Center(
                  child: Image.asset(
                    'assets/***/app_icon_tr.png',
                    width: 100,
                    height: 100,
                    cacheHeight: 100,
                    cacheWidth: 100,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ScaffoldLineIndicator extends StatefulWidget {
  const ScaffoldLineIndicator({super.key});

  @override
  State<ScaffoldLineIndicator> createState() => _ScaffoldLineIndicatorState();
}

class _ScaffoldLineIndicatorState extends State<ScaffoldLineIndicator> {
  double _value = 1.0;

  @override
  void initState() {
    scheduleMicrotask(_run);

    super.initState();
  }

  Future<void> _run() async {
    setState(() {
      if (_value == 0.3) {
        _value = 1.0;
      } else {
        _value = 0.3;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 1.5,
          width: context.width,
          color: AppTheme.clBlack,
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 1000),
          opacity: _value,
          onEnd: _run,
          child: Container(
            height: 1.5,
            width: context.width,
            color: AppTheme.clYellow,
          ),
        ),
      ],
    );
  }
}

class ScaffoldTopIconIndicator extends StatefulWidget {
  const ScaffoldTopIconIndicator({
    super.key,
    required this.ctrl,
    required this.onRefresh,
  });

  final ScrollController? ctrl;
  final Future<void> Function()? onRefresh;

  @override
  State<ScaffoldTopIconIndicator> createState() =>
      _ScaffoldTopIconIndicatorState();
}

class _ScaffoldTopIconIndicatorState extends State<ScaffoldTopIconIndicator> {
  late DateTime _lastRefresh;
  late Future<void> Function() _listener;

  bool _hitRefresh = false;
  bool _rotate = false;

  @override
  void initState() {
    _lastRefresh = DateTime.now();
    _listener = _refresh;

    if (widget.ctrl != null && widget.onRefresh != null) {
      widget.ctrl!.addListener(_listener);
    }

    super.initState();
  }

  @override
  void dispose() {
    if (widget.ctrl != null) {
      widget.ctrl!.removeListener(_listener);
    }

    super.dispose();
  }

  Future<void> _refresh() async {
    final position = widget.ctrl!.position;
    if (position.pixels < 0 && position.pixels.abs() >= 130) {
      if (_hitRefresh) return;
      _hitRefresh = true;

      fnHaptic();

      setState(() {
        _rotate = true;
      });
    }

    if (position.pixels.abs() <= 0) {
      if (!_hitRefresh) return;
      _hitRefresh = false;

      if (DateTime.now().difference(_lastRefresh).inMilliseconds <= 1000) {
        return;
      }

      _lastRefresh = DateTime.now();

      widget.onRefresh?.call();
      widget.ctrl!.animateTo(0, duration: 100.mlsec, curve: Curves.linear);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      height: 50,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 15),
      child: AnimatedRotation(
        duration: const Duration(milliseconds: 500),
        turns: _rotate ? -math.pi / 11 : 0,
        onEnd: () {
          setState(() {
            _rotate = false;
          });
        },
        child: Image.asset(
          'assets/***/app_icon_tr.png',
          scale: 5,
          cacheHeight: 139,
          cacheWidth: 132,
        ),
      ),
    );
  }
}

class ScaffoldBottomIconIndicator extends StatefulWidget {
  const ScaffoldBottomIconIndicator({
    super.key,
    required this.ctrl,
    required this.onLoadMore,
    required this.hideBack,
    required this.animate,
  });

  final ScrollController? ctrl;
  final Future<void> Function()? onLoadMore;
  final bool hideBack;
  final bool animate;

  @override
  State<ScaffoldBottomIconIndicator> createState() =>
      _ScaffoldBottomIconIndicatorState();
}

class _ScaffoldBottomIconIndicatorState
    extends State<ScaffoldBottomIconIndicator> {
  late DateTime _lastLoadMore;
  late Future<void> Function() _listener;

  bool _hitLoadMore = false;
  bool _rotate = false;

  @override
  void initState() {
    _lastLoadMore = DateTime.now();

    if (widget.ctrl != null) {
      if (widget.onLoadMore != null) {
        _listener = _loadMore;
      } else {
        _listener = _noLoadMore;
      }

      widget.ctrl!.addListener(_listener);
    }

    super.initState();
  }

  @override
  void dispose() {
    if (widget.ctrl != null) {
      widget.ctrl!.removeListener(_listener);
    }

    super.dispose();
  }

  Future<void> _noLoadMore() async {
    double pixels = widget.ctrl!.position.pixels;
    if (pixels > 1) {
      widget.ctrl!.jumpTo(0);
    }

    return;
  }

  Future<void> _loadMore() async {
    final position = widget.ctrl!.position;
    if (position.pixels >= position.maxScrollExtent + 100) {
      if (_hitLoadMore) return;
      _hitLoadMore = true;

      fnHaptic();

      setState(() {
        _rotate = true;
      });
    }

    if (position.pixels <= position.maxScrollExtent) {
      if (!_hitLoadMore) return;
      _hitLoadMore = false;

      if (DateTime.now().difference(_lastLoadMore).inSeconds <= 1) {
        return;
      }

      _lastLoadMore = DateTime.now();

      await widget.onLoadMore?.call();

      if (widget.animate) {
        await Future.delayed(250.mlsec);

        double toP = position.pixels + 450;
        if (toP + 50 < position.maxScrollExtent) {
          widget.ctrl!.animateTo(
            position.pixels + 450,
            duration: 400.mlsec,
            curve: Curves.linear,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double bottom =
        widget.hideBack ? AppTheme.appNavHeight + 10 : context.notch;

    return Container(
      padding: EdgeInsets.only(bottom: bottom),
      alignment: Alignment.bottomCenter,
      child: AnimatedRotation(
        duration: const Duration(milliseconds: 500),
        turns: _rotate ? -math.pi / 11 : 0,
        onEnd: () {
          setState(() {
            _rotate = false;
          });
        },
        child: Image.asset(
          'assets/***/app_icon_tr.png',
          scale: 5,
          cacheHeight: 139,
          cacheWidth: 132,
        ),
      ),
    );
  }
}
