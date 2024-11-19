// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/avatar_image.dart';
import 'package:trailcatch/widgets/buttons/option_button.dart';
import 'package:trailcatch/widgets/scaffolds/bottom_scaffold.dart';

class TrailWithDogsSheet extends StatefulWidget {
  const TrailWithDogsSheet({
    super.key,
    required this.trailExt,
  });

  final TrailExtModel trailExt;

  @override
  State<TrailWithDogsSheet> createState() => _TrailWithDogsSheetState();
}

class _TrailWithDogsSheetState extends State<TrailWithDogsSheet> {
  late List<String> _dogsIds;

  @override
  void initState() {
    _dogsIds = List<String>.from(widget.trailExt.trail.dogsIds);

    scheduleMicrotask(() {
      Future.delayed(250.mlsec, () {
        if (widget.trailExt.user.dogs.length == 1) {
          if (!_dogsIds.contains(widget.trailExt.user.dogs.first.dogId)) {
            setState(() {
              _dogsIds.add(widget.trailExt.user.dogs.first.dogId);
            });
          }
        }
      });
    });

    super.initState();
  }

  bool _isChanged() {
    return !listEquals(_dogsIds, widget.trailExt.trail.dogsIds);
  }

  @override
  Widget build(BuildContext context) {
    final bool isChanged0 = _isChanged();

    return AppBottomScaffold(
      title: 'Dogs',
      isChanged: isChanged0,
      onBack: () {
        widget.trailExt.trail.dogsIds = _dogsIds;

        return isChanged0;
      },
      child: Container(
        width: context.width,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            for (var dog in widget.trailExt.user.dogs)
              Column(
                children: [
                  Container(
                    color: AppTheme.clBackground,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppAvatarImage(
                          size: 40,
                          pictureFile: dog.cachePictureFile,
                          isInOurHearts: dog.inOurHeartsDateAt != null,
                        ),
                        14.w,
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              dog.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        10.w,
                        SizedBox(
                          width: context.width * 0.25,
                          child: AppOptionButton(
                            value: _dogsIds.contains(dog.dogId) ? 'On' : 'Off',
                            opts: const ['Off', 'On'],
                            onValueChanged: (value) async {
                              setState(() {
                                if (value == 'On') {
                                  if (!_dogsIds.contains(dog.dogId)) {
                                    _dogsIds.add(dog.dogId);
                                  }
                                } else if (value == 'Off') {
                                  if (_dogsIds.contains(dog.dogId)) {
                                    _dogsIds.remove(dog.dogId);
                                  }
                                }
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  if (widget.trailExt.user.dogs.last != dog) 10.hrr(height: 2),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
