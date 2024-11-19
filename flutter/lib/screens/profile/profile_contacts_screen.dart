// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';

import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';
import 'package:trailcatch/widgets/textfield.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileContactsScreen extends StatefulWidget {
  const ProfileContactsScreen({
    super.key,
    required this.contacts,
  });

  final Map<String, dynamic> contacts;

  @override
  State<ProfileContactsScreen> createState() => _ProfileContactsScreenState();
}

class _ProfileContactsScreenState extends State<ProfileContactsScreen> {
  late final TextEditingController _instagramCtrl;
  late final TextEditingController _facebookCtrl;
  late final TextEditingController _twitterCtrl;
  late final TextEditingController _stravaCtrl;
  late final TextEditingController _youtubeCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    _instagramCtrl = TextEditingController(
      text: widget.contacts[UserContact.instagram] ?? '',
    );
    _facebookCtrl = TextEditingController(
      text: widget.contacts[UserContact.facebook] ?? '',
    );
    _twitterCtrl = TextEditingController(
      text: widget.contacts[UserContact.twitter] ?? '',
    );
    _stravaCtrl = TextEditingController(
      text: widget.contacts[UserContact.strava] ?? '',
    );
    _youtubeCtrl = TextEditingController(
      text: widget.contacts[UserContact.youtube] ?? '',
    );
    _emailCtrl = TextEditingController(
      text: widget.contacts[UserContact.email] ?? '',
    );

    super.initState();
  }

  @override
  void dispose() {
    _instagramCtrl.dispose();
    _facebookCtrl.dispose();
    _twitterCtrl.dispose();
    _stravaCtrl.dispose();
    _youtubeCtrl.dispose();
    _emailCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSimpleScaffold(
      onBack: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        AppRoute.goBack();
      },
      title: 'Contacts',
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
      children: [
        10.h,
        Row(
          children: [
            Expanded(
              child: AppTextField(
                title: UserContact.instagram.toTitle(),
                ctrl: _instagramCtrl,
                placeholder: 'Instagram username',
                onFocusLost: () {
                  setState(() {
                    widget.contacts[UserContact.instagram] =
                        _instagramCtrl.text.trim();
                  });
                },
              ),
            ),
            if (_instagramCtrl.text.isNotEmpty) ...[
              8.w,
              Container(
                color: AppTheme.clBackground,
                padding: const EdgeInsets.only(top: 23),
                child: AppGestureButton(
                  child: const Icon(Icons.close, color: AppTheme.clRed),
                  onTap: () {
                    setState(() {
                      _instagramCtrl.text = '';
                      widget.contacts[UserContact.instagram] = '';
                    });
                  },
                ),
              ),
            ],
          ],
        ),
        if (_instagramCtrl.text.isNotEmpty)
          AppGestureButton(
            onTry: () async {
              launchUrl(Uri.parse(
                '${UserContact.linstagram}${_instagramCtrl.text.trim()}',
              ));
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 4, left: 4),
              width: context.width,
              color: AppTheme.clBackground,
              child: Text(
                '${UserContact.lhinstagram}${_instagramCtrl.text.trim()}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.clYellow,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        0.dl,
        Row(
          children: [
            Expanded(
              child: AppTextField(
                title: UserContact.facebook.toTitle(),
                ctrl: _facebookCtrl,
                placeholder: 'Facebook username',
                onFocusLost: () {
                  setState(() {
                    widget.contacts[UserContact.facebook] =
                        _facebookCtrl.text.trim();
                  });
                },
              ),
            ),
            if (_facebookCtrl.text.isNotEmpty) ...[
              8.w,
              Container(
                color: AppTheme.clBackground,
                padding: const EdgeInsets.only(top: 23),
                child: AppGestureButton(
                  child: const Icon(Icons.close, color: AppTheme.clRed),
                  onTap: () {
                    setState(() {
                      _facebookCtrl.text = '';
                      widget.contacts[UserContact.facebook] = '';
                    });
                  },
                ),
              ),
            ],
          ],
        ),
        if (_facebookCtrl.text.isNotEmpty)
          AppGestureButton(
            onTry: () async {
              launchUrl(Uri.parse(
                '${UserContact.lfacebook}${_facebookCtrl.text.trim()}',
              ));
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 4, left: 4),
              width: context.width,
              color: AppTheme.clBackground,
              child: Text(
                '${UserContact.lhfacebook}${_facebookCtrl.text.trim()}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.clYellow,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        0.dl,
        Row(
          children: [
            Expanded(
              child: AppTextField(
                title: UserContact.twitter.toTitle(),
                ctrl: _twitterCtrl,
                placeholder: 'X username',
                onFocusLost: () {
                  setState(() {
                    widget.contacts[UserContact.twitter] =
                        _twitterCtrl.text.trim();
                  });
                },
              ),
            ),
            if (_twitterCtrl.text.isNotEmpty) ...[
              8.w,
              Container(
                color: AppTheme.clBackground,
                padding: const EdgeInsets.only(top: 23),
                child: AppGestureButton(
                  child: const Icon(Icons.close, color: AppTheme.clRed),
                  onTap: () {
                    setState(() {
                      _twitterCtrl.text = '';
                      widget.contacts[UserContact.twitter] = '';
                    });
                  },
                ),
              ),
            ],
          ],
        ),
        if (_twitterCtrl.text.isNotEmpty)
          AppGestureButton(
            onTry: () async {
              launchUrl(Uri.parse(
                '${UserContact.ltwitter}${_twitterCtrl.text.trim()}',
              ));
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 4, left: 4),
              width: context.width,
              color: AppTheme.clBackground,
              child: Text(
                '${UserContact.lhtwitter}${_twitterCtrl.text.trim()}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.clYellow,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        0.dl,
        Row(
          children: [
            Expanded(
              child: AppTextField(
                title: UserContact.strava.toTitle(),
                ctrl: _stravaCtrl,
                placeholder: 'Strava username',
                onFocusLost: () {
                  setState(() {
                    widget.contacts[UserContact.strava] =
                        _stravaCtrl.text.trim();
                  });
                },
              ),
            ),
            if (_stravaCtrl.text.isNotEmpty) ...[
              8.w,
              Container(
                color: AppTheme.clBackground,
                padding: const EdgeInsets.only(top: 23),
                child: AppGestureButton(
                  child: const Icon(Icons.close, color: AppTheme.clRed),
                  onTap: () {
                    setState(() {
                      _stravaCtrl.text = '';
                      widget.contacts[UserContact.strava] = '';
                    });
                  },
                ),
              ),
            ],
          ],
        ),
        if (_stravaCtrl.text.isNotEmpty)
          AppGestureButton(
            onTry: () async {
              launchUrl(Uri.parse(
                '${UserContact.lstrava}${_stravaCtrl.text.trim()}',
              ));
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 4, left: 4),
              width: context.width,
              color: AppTheme.clBackground,
              child: Text(
                '${UserContact.lhstrava}${_stravaCtrl.text.trim()}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.clYellow,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        0.dl,
        Row(
          children: [
            Expanded(
              child: AppTextField(
                title: UserContact.youtube.toTitle(),
                ctrl: _youtubeCtrl,
                placeholder: 'Youtube username',
                onFocusLost: () {
                  setState(() {
                    widget.contacts[UserContact.youtube] =
                        _youtubeCtrl.text.trim();
                  });
                },
              ),
            ),
            if (_youtubeCtrl.text.isNotEmpty) ...[
              8.w,
              Container(
                color: AppTheme.clBackground,
                padding: const EdgeInsets.only(top: 23),
                child: AppGestureButton(
                  child: const Icon(Icons.close, color: AppTheme.clRed),
                  onTap: () {
                    setState(() {
                      _youtubeCtrl.text = '';
                      widget.contacts[UserContact.youtube] = '';
                    });
                  },
                ),
              ),
            ],
          ],
        ),
        if (_youtubeCtrl.text.isNotEmpty)
          AppGestureButton(
            onTry: () async {
              launchUrl(Uri.parse(
                '${UserContact.lyoutube}${_youtubeCtrl.text.trim()}',
              ));
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 4, left: 4),
              width: context.width,
              color: AppTheme.clBackground,
              child: Text(
                '${UserContact.lhyoutube}${_youtubeCtrl.text.trim()}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.clYellow,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        0.dl,
        Row(
          children: [
            Expanded(
              child: AppTextField(
                title: UserContact.email.toTitle(),
                ctrl: _emailCtrl,
                placeholder: 'Email',
                onFocusLost: () {
                  setState(() {
                    widget.contacts[UserContact.email] = _emailCtrl.text.trim();
                  });
                },
              ),
            ),
            if (_emailCtrl.text.isNotEmpty) ...[
              8.w,
              Container(
                color: AppTheme.clBackground,
                padding: const EdgeInsets.only(top: 23),
                child: AppGestureButton(
                  child: const Icon(Icons.close, color: AppTheme.clRed),
                  onTap: () {
                    setState(() {
                      _emailCtrl.text = '';
                      widget.contacts[UserContact.email] = '';
                    });
                  },
                ),
              ),
            ],
          ],
        ),
        if (_emailCtrl.text.isNotEmpty)
          AppGestureButton(
            onTry: () async {
              launchUrl(Uri.parse(
                '${UserContact.lemail}${_emailCtrl.text.trim()}',
              ));
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 4, left: 4),
              width: context.width,
              color: AppTheme.clBackground,
              child: Text(
                '${UserContact.lhemail}${_emailCtrl.text.trim()}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.clYellow,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
      ],
    );
  }
}
