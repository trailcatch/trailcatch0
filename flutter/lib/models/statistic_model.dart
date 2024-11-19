// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:collection/collection.dart';

class StatisticModel {
  StatisticModel({
    required this.type,
    required this.dogsIds,
    // --
    required this.count,
    required this.distance,
    required this.elevation,
    required this.time,
    // --
    required this.avgPace,
    required this.avgSpeed,
    // --
    required this.dateAt,
  });

  final int type;
  final List<String> dogsIds;
  // --
  final int count;
  final int distance;
  final int elevation;
  final int time;
  // --
  final int avgPace;
  final int avgSpeed;
  // --
  final DateTime dateAt;

  factory StatisticModel.fromJson(Map<String, dynamic> json) {
    return StatisticModel(
      type: json['type'],
      dogsIds: List<String>.from(json['dogs_ids']),
      // --
      count: json['count'],
      distance: json['distance'],
      elevation: json['elevation'],
      time: json['time'],
      // --
      avgPace: (json['avg_pace'] as num).toInt(),
      avgSpeed: (json['avg_speed'] as num).toInt(),
      // --
      dateAt: DateTime.parse(json['date_at']),
    );
  }
}

class StatisticMonthModel {
  StatisticMonthModel({
    required this.count,
    required this.distance,
    required this.elevation,
    required this.time,
    required this.avgPaces,
    required this.avgSpeeds,
    required this.days,
    required this.dateAt,
  });

  final int count;
  final int distance;
  final int elevation;
  final int time;
  final List<int> avgPaces;
  final List<int> avgSpeeds;
  final List<int> days;
  final DateTime dateAt;

  int get avgPace => avgPaces.isNotEmpty ? avgPaces.average.toInt() : 0;
  int get avgSpeed => avgSpeeds.isNotEmpty ? avgSpeeds.average.toInt() : 0;

  factory StatisticMonthModel.empty(DateTime dateAt) {
    return StatisticMonthModel(
      count: 0,
      distance: 0,
      elevation: 0,
      time: 0,
      avgPaces: [],
      avgSpeeds: [],
      days: [],
      dateAt: dateAt,
    );
  }
}

class StatisticLatestMonthsModel {
  StatisticLatestMonthsModel({
    required this.count,
    required this.distance,
    required this.elevation,
    required this.time,
  });

  int count;
  int distance;
  int elevation;
  int time;

  factory StatisticLatestMonthsModel.empty() {
    return StatisticLatestMonthsModel(
      count: 0,
      distance: 0,
      elevation: 0,
      time: 0,
    );
  }
}

class StatisticTypeModel {
  StatisticTypeModel({
    required this.type,
    required this.count,
    required this.distance,
    required this.elevation,
    required this.time,
    required this.avgPaces,
    required this.avgSpeeds,
    required this.dogsIds,
    required this.dateAt,
  });

  final int type;
  final int count;
  final int distance;
  final int elevation;
  final int time;
  final List<int> avgPaces;
  final List<int> avgSpeeds;
  final List<String> dogsIds;
  final DateTime dateAt;

  int get avgPace => avgPaces.isNotEmpty ? avgPaces.average.toInt() : 0;
  int get avgSpeed => avgSpeeds.isNotEmpty ? avgSpeeds.average.toInt() : 0;

  factory StatisticTypeModel.empty(DateTime dateAt) {
    return StatisticTypeModel(
      type: 0,
      count: 0,
      distance: 0,
      elevation: 0,
      time: 0,
      avgPaces: [],
      avgSpeeds: [],
      dogsIds: [],
      dateAt: dateAt,
    );
  }
}
