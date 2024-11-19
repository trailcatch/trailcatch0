// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/models/user_model.dart';

class NotifModel {
  NotifModel({
    required this.notifId,
    // --
    required this.user1Id,
    required this.trail1Id,
    // --
    required this.user2Id,
    // --
    required this.read,
    // --
    required this.createdAt,
  });

  final int notifId;
  // --
  final String user1Id;
  final String? trail1Id;
  // --
  final String user2Id;
  // --
  bool read;
  // --
  final DateTime createdAt;

  factory NotifModel.fromJson(Map<String, dynamic> json) {
    return NotifModel(
      notifId: json['notif_id'],
      // --
      user1Id: json['user1_id'],
      trail1Id: json['trail1_id'],
      // --
      user2Id: json['user2_id'],
      // --
      read: json['read'],
      // --
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}

class NotifExtModel {
  NotifExtModel({
    required this.notif,
    required this.trail,
    required this.user2,
    required this.latestTrail2,
  });

  final NotifModel notif;
  final TrailModel? trail;
  final UserModel? user2;
  final TrailModel? latestTrail2;

  factory NotifExtModel.fromJson(Map<String, dynamic> json) {
    TrailModel? trail;
    if (json['trail1'] != null) {
      trail = TrailModel.fromJson(json['trail1']);
    }

    TrailModel? latestTrail2;
    if (json['latest_trail2'] != null) {
      if (json['latest_trail2']['trail_id'] == null) {
        latestTrail2 = TrailModel.empty();
      } else {
        if (json['latest_trail2']['notpub'] == true ||
            json['latest_trail2']['intrash'] == true) {
          latestTrail2 = TrailModel.empty();
        } else {
          latestTrail2 = TrailModel.fromJson(json['latest_trail2']);
        }
      }
    }

    UserModel? user2;
    if (json['user2'] != null) {
      user2 = UserModel.fromJson(json['user2']);
    }

    return NotifExtModel(
      notif: NotifModel.fromJson(json['notif']),
      trail: trail,
      user2: user2,
      latestTrail2: latestTrail2,
    );
  }
}
