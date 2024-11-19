// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:fc_native_image_resize/fc_native_image_resize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/buttons/option_button.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';
import 'package:trailcatch/widgets/tcid.dart';

class TrailShareSheet extends StatefulWidget {
  const TrailShareSheet({
    super.key,
    required this.trail,
  });

  final TrailModel trail;

  @override
  State<TrailShareSheet> createState() => _TrailShareSheetState();
}

class _TrailShareSheetState extends State<TrailShareSheet> {
  final GlobalKey gKey = GlobalKey();

  late String _link;
  late String _text;
  late String _textShort;

  late int _shareType;

  @override
  void initState() {
    _shareType = 2;

    final String encrTrailId = fnEncodeAES(widget.trail.trailId);

    _link = 'https://app.trailcatch.com/t/$encrTrailId';
    _text = 'My Trail on TrailCatch - $_link';

    _textShort = 'My Trail on TrailCatch - https://app.trailcatch.com/t/';
    _textShort +=
        '${encrTrailId.substring(0, 4)}...${encrTrailId.substring(encrTrailId.length - 5, encrTrailId.length)}';

    super.initState();
  }

  Future<void> _shareAsText() async {
    await Share.share(_text, subject: 'TrailCatch\n$_text');
  }

  Future<void> _shareAsImage() async {
    final RenderRepaintBoundary boundary =
        gKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 10.0);

    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final dirPath = (await getTemporaryDirectory()).path;
    final File file0 = File(
      '$dirPath/***__${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file0.writeAsBytes(pngBytes.buffer.asInt8List());

    if (_shareType == 1) {
      final File file = File(
        '$dirPath/***__${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await FcNativeImageResize().resizeFile(
        srcFile: file0.path,
        destFile: file.path,
        width: 180,
        height: 210,
        keepAspectRatio: true,
        format: 'jpg',
        quality: 100,
      );

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'TrailCatch',
        text: _text,
      );
    } else {
      await Share.shareXFiles(
        [XFile(file0.path)],
        subject: 'TrailCatch',
        text: _text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String shareValueStr = _shareType == 0
        ? 'Link'
        : (_shareType == 1 ? 'Link & Image' : 'Link & QR');

    return AppBottomScaffold(
      title: 'Share Trail',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppOptionButton(
              value: shareValueStr,
              opts: const ['Link', 'Link & Image', 'Link & QR'],
              textColor: AppTheme.clText07,
              onValueChanged: (value) async {
                if (value == 'Link') {
                  setState(() {
                    _shareType = 0;
                  });
                } else if (value == 'Link & Image') {
                  setState(() {
                    _shareType = 1;
                  });
                } else if (value == 'Link & QR') {
                  setState(() {
                    _shareType = 2;
                  });
                }
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_shareType != 0)
                  Stack(
                    children: [
                      Opacity(
                        opacity: _shareType == 1 ? 0.0 : 1.0,
                        child: Container(
                          padding: const EdgeInsets.only(top: 10),
                          child: RepaintBoundary(
                            key: gKey,
                            child: TrailShareCanvas(
                              trail: widget.trail,
                              shareType: _shareType,
                              link: _link,
                              isQR: _shareType == 2,
                              scaleOn: _shareType == 2,
                            ),
                          ),
                        ),
                      ),
                      if (_shareType == 1)
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          child: TrailShareCanvas(
                            trail: widget.trail,
                            shareType: _shareType,
                            link: _link,
                            isQR: false,
                            scaleOn: true,
                          ),
                        )
                    ],
                  )
                else
                  10.h,
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.clBlack,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.appLR,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.only(top: 5),
                  child: Text(
                    _textShort,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            15.h,
            Center(
              child: AppSimpleButton(
                width: context.width * AppTheme.appBtnWidth,
                text: 'Share as $shareValueStr',
                onTry: _shareType == 0 ? _shareAsText : _shareAsImage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrailShareCanvas extends StatelessWidget {
  const TrailShareCanvas({
    super.key,
    required this.trail,
    required this.shareType,
    required this.link,
    required this.isQR,
    required this.scaleOn,
  });

  final TrailModel trail;
  final int shareType;
  final String link;
  final bool isQR;
  final bool scaleOn;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.clBackground,
      padding: const EdgeInsets.symmetric(vertical: 5),
      width: scaleOn ? 210 : 25,
      height: scaleOn ? null : 35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: AppTCID(
              trail: trail,
              height: 100,
              leftTxt: 'TrailCatch',
              labelColor: AppTheme.clYellow,
              leftColor: AppTheme.clText,
            ),
          ),
          if (isQR) ...[
            3.w,
            Image.asset(
              'assets/***/app_icon_tr.png',
              scale: 7,
              cacheHeight: 99,
              cacheWidth: 94,
            ),
            QrImageView(
              data: link,
              version: QrVersions.auto,
              size: 90,
              gapless: false,
              eyeStyle: QrEyeStyle(
                color: AppTheme.clText09,
                eyeShape: QrEyeShape.square,
              ),
              dataModuleStyle: QrDataModuleStyle(
                color: AppTheme.clText09,
                dataModuleShape: QrDataModuleShape.square,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
