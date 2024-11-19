// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/screens/notifications/notifications_screen.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/device_utils.dart';
import 'package:trailcatch/utils/pref_utils.dart';

abstract class TrailType {
  static const int walk = 1;
  static const int run = 2;
  static const int bike = 3;

  static List<int> get all {
    return [TrailType.walk, TrailType.run, TrailType.bike];
  }

  static List<String> get allStr {
    return ['Walk', 'Run', 'Bike'];
  }

  static List<String> get allExtStr {
    return [
      'All Trails',
      'Walk',
      'Walk & Dogs',
      'Run',
      'Run & Dogs',
      'Bike',
      'Bike & Dogs',
    ];
  }

  static String? formatToStr(int? type) {
    if (type == TrailType.walk) return 'Walk';
    if (type == TrailType.run) return 'Run';
    if (type == TrailType.bike) return 'Bike';

    return null;
  }

  static int? formatToType(String? typeStr) {
    if (typeStr == 'Walk') return TrailType.walk;
    if (typeStr == 'Run') return TrailType.run;
    if (typeStr == 'Bike') return TrailType.bike;

    return null;
  }

  static IconData? formatTypeToIcon(int type) {
    if (type == TrailType.walk) return Icons.directions_walk_rounded;
    if (type == TrailType.run) return Icons.directions_run_outlined;
    if (type == TrailType.bike) return Icons.pedal_bike_rounded;

    return null;
  }
}

class TrailModel {
  TrailModel({
    required this.trailId,
    required this.userId,
    // --
    required this.type,
    required this.datetimeAt,
    required this.distance,
    required this.elevation,
    required this.time,
    // --
    required this.avgPace,
    required this.avgSpeed,
    // --
    required this.dogsIds,
    // --
    required this.deviceId,
    required this.deviceDataId,
    required this.deviceData,
    required this.deviceGeopoints,
    // --
    required this.inTrash,
    required this.notPub,
    // --
    required this.pubAt,
    required this.createdAt,
  });

  final String trailId;
  final String userId;
  // --
  int type;
  final DateTime datetimeAt;
  final int distance;
  final int elevation;
  final int time;
  // --
  final int avgPace;
  final int avgSpeed;
  // --
  List<String> dogsIds;
  // --
  final int deviceId;
  final String deviceDataId;
  TrailDeviceData? deviceData;
  List<LatLng>? deviceGeopoints;
  // --
  bool inTrash;
  bool notPub;
  // --
  DateTime? pubAt;
  final DateTime? createdAt;

  bool get isEmpt => trailId.isEmpty;

  bool get isFit => deviceDataId.endsWith('f');

  factory TrailModel.fromJson(Map<String, dynamic> json) {
    bool notPub = json['notpub'];
    final bool inTrash = json['intrash'];
    if (inTrash) {
      notPub = false;
    }

    TrailDeviceData? deviceData;
    if (json['device_data'] != null) {
      if (json['device_data']['type'] == null) {
        json['device_data']['type'] = json['type'];
      }

      deviceData = TrailDeviceData.fromJson(json['device_data']);
    }

    return TrailModel(
      trailId: json['trail_id'],
      userId: json['user_id'],
      // --
      type: json['type'],
      datetimeAt: DateTime.parse(json['datetime_at']).toLocal(),
      distance: json['distance'],
      elevation: json['elevation'],
      time: json['time'],
      // --
      avgPace: json['avg_pace'],
      avgSpeed: json['avg_speed'],
      // --
      dogsIds: List<String>.from(json['dogs_ids'] ?? []),
      // --
      deviceId: json['device'],
      deviceDataId: json['device_data_id'],
      deviceData: deviceData,
      deviceGeopoints: LatLng.fromPGMultiPointSRID(json['device_geopoints']),
      // --
      inTrash: inTrash,
      notPub: notPub,
      // --
      pubAt: DateTime.tryParse(json['pub_at'] ?? '')?.toLocal(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '')?.toLocal(),
    );
  }

  factory TrailModel.empty({
    String? trailId,
    int? type,
    int? distance,
    int? time,
    int? avgPace,
    int? avgSpeed,
    List<String>? dogsIds,
  }) {
    return TrailModel(
      trailId: trailId ?? '',
      userId: '',
      // --
      type: type ?? 0,
      datetimeAt: DateTime(1900),
      distance: distance ?? 0,
      elevation: 0,
      time: time ?? 0,
      // --
      avgPace: avgPace ?? 0,
      avgSpeed: avgSpeed ?? 0,
      // --
      dogsIds: dogsIds ?? [],
      // --
      deviceId: 0,
      deviceDataId: '',
      deviceData: null,
      deviceGeopoints: null,
      // --
      inTrash: false,
      notPub: false,
      // --
      createdAt: DateTime(1900),
      pubAt: null,
    );
  }
}

class TrailExtModel {
  TrailExtModel({
    required this.trail,
    required this.user,
    // --

    required this.likes,
    required this.likedByMe,
    required this.likesLatest4,
    // --
    this.likeCreatedAt,
  });

  final TrailModel trail;
  final UserModel user;
  // --
  int likes;
  bool likedByMe;
  List<String> likesLatest4;

  // --

  DateTime? likeCreatedAt;

  // --

  bool get withDogs => trail.dogsIds.isNotEmpty;
  List<String> get dogsNames {
    return user.dogs0.fold([], (acc, it) {
      if (trail.dogsIds.contains(it.dogId)) {
        acc.add(it.name);
      }
      return acc;
    });
  }

  bool get isMy => appVM.user.userId == trail.userId;

  bool get isWalk => trail.type == TrailType.walk;
  bool get isRun => trail.type == TrailType.run;
  bool get isBike => trail.type == TrailType.bike;

  factory TrailExtModel.fromJson(
    Map<String, dynamic> json, {
    UserModel? user,
    bool skipNotPubAndInTrash = false,
  }) {
    UserModel? user0 = user ?? UserModel.fromJson(json['user']);
    DateTime? likeCreatedAt =
        DateTime.tryParse(json['like_created_at'] ?? '')?.toLocal();

    final TrailExtModel trailExtEmpt = TrailExtModel(
      trail: TrailModel.empty(),
      user: user0,
      // --
      likes: 0,
      likedByMe: false,
      likesLatest4: [],
      // --
      likeCreatedAt: likeCreatedAt,
    );

    if (json['trail'] == null || json['trail']['trail_id'] == null) {
      return trailExtEmpt;
    }

    if (skipNotPubAndInTrash) {
      if (json['trail']['notpub'] == true || json['trail']['intrash'] == true) {
        return trailExtEmpt;
      }
    }

    return TrailExtModel(
      trail: TrailModel.fromJson(json['trail']),
      user: user0,
      // --
      likes: json['likes'],
      likedByMe: json['liked_by_me'],
      likesLatest4: List<String>.from(json['likes_latest_4']),
      // --
      likeCreatedAt: likeCreatedAt,
    );
  }

  factory TrailExtModel.fromTrail(TrailModel trail) {
    return TrailExtModel(
      trail: trail,
      user: appVM.user,
      likes: 0,
      likedByMe: false,
      likesLatest4: [],
    );
  }
}

class TrailFilters {
  TrailFilters({
    this.trailType,
    this.strangesOnly,
    this.withDogs,
    required this.genders,
    required this.ageGroups,
    required this.uiso3s,
    required this.dogsBreed,
  });

  int? trailType;
  bool? strangesOnly;
  bool? withDogs;
  List<int> genders;
  List<String> ageGroups;
  List<String> uiso3s;
  List<int> dogsBreed;

  List<int> ageGroupsToInt() {
    if (ageGroups.isEmpty) return [];

    List<int> ages = [];

    final List<(String, List<int>)> ageGroupsS = fnAgeGroupsS();
    for (var ageGroupS in ageGroupsS) {
      for (var ageGroup in ageGroups) {
        if (ageGroupS.$1 == ageGroup) {
          final lst = List.generate(
            ageGroupS.$2.last - ageGroupS.$2.first + 1,
            (i) => ageGroupS.$2.first + i,
          );

          ages.addAll(lst);
        }
      }
    }

    ages.sort();

    return ages;
  }

  static Future<TrailFilters> build() async {
    return TrailFilters.fromJson(await fnPrefGetTrailFilters());
  }

  factory TrailFilters.fromJson(Map<String, dynamic> json) {
    return TrailFilters(
      trailType: json['trailType'],
      strangesOnly: json['strangesOnly'],
      withDogs: json['withDogs'],
      genders: List<int>.from(json['genders'] ?? []),
      ageGroups: List<String>.from(json['ageGroups'] ?? []),
      uiso3s: List<String>.from(json['uiso3s'] ?? []),
      dogsBreed: List<int>.from(json['dogsBreed'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trailType': trailType,
      'strangesOnly': strangesOnly,
      'withDogs': withDogs,
      'genders': List<int>.from(genders)..sort(),
      'ageGroups': List<String>.from(ageGroups)..sort(),
      'uiso3s': List<String>.from(uiso3s)..sort(),
      'dogsBreed': List<int>.from(dogsBreed)..sort(),
    };
  }

  Future<void> refresh() async {
    final json = await fnPrefGetTrailFilters();

    trailType = json['trailType'];
    strangesOnly = json['strangesOnly'];
    withDogs = json['withDogs'];
    genders = List<int>.from(json['genders'] ?? []);
    ageGroups = List<String>.from(json['ageGroups'] ?? []);
    uiso3s = List<String>.from(json['uiso3s'] ?? []);
    dogsBreed = List<int>.from(json['dogsBreed'] ?? []);
  }

  Future<void> save() async {
    await fnPrefSaveTrailFilters(toJson());
  }

  Future<void> clear() async {
    trailType = null;
    strangesOnly = null;
    withDogs = null;
    genders.clear();
    ageGroups.clear();
    uiso3s.clear();
    dogsBreed.clear();

    await fnPrefClearTrailFilters();
  }

  bool get isEmpty {
    return trailType == null &&
        withDogs == null &&
        genders.isEmpty &&
        ageGroups.isEmpty &&
        uiso3s.isEmpty &&
        dogsBreed.isEmpty;
  }

  bool get isEmptyWithStranges {
    return isEmpty && strangesOnly == null;
  }

  Future<bool> isChanged() async {
    final json1 = toJson();
    final json2 = await fnPrefGetTrailFilters();

    bool isChanged = json1['trailType'] != json2['trailType'] ||
        json1['strangesOnly'] != json2['strangesOnly'] ||
        json1['withDogs'] != json2['withDogs'] ||
        !listEquals(json1['genders'], json2['genders']) ||
        !listEquals(json1['ageGroups'], json2['ageGroups']) ||
        !listEquals(json1['uiso3s'], json2['uiso3s']) ||
        !listEquals(json1['dogsBreed'], json2['dogsBreed']);

    return isChanged;
  }
}

class TrailDeviceData {
  TrailDeviceData({
    required this.type,
    required this.deviceModel,
    required this.deviceModelOn,
    //
    required this.msrunit,
    //
    required this.distances,
    required this.times,
    required this.paces,
    required this.avgPace,
    required this.minPace,
    required this.speeds,
    required this.avgSpeed,
    required this.maxSpeed,
    required this.pacesOn,
    required this.speedsOn,
    //
    required this.heartRates,
    required this.avgHeartRate,
    required this.maxHeartRate,
    required this.heartRatesOn,
    //
    required this.cadences,
    required this.avgCadence,
    required this.maxCadence,
    required this.cadencesOn,
    //
    required this.altitudes,
    required this.totalAscent,
    required this.totalDescent,
    //
    required this.powers,
    required this.avgPower,
    required this.maxPower,
    required this.powersOn,
    //
    required this.respRates,
    required this.avgRespRate,
    required this.maxRespRate,
    required this.minRespRate,
    required this.respRatesOn,
    //
    required this.calories,
    //
    required this.effectAerobic,
    required this.effectAnaerobic,
    required this.teOn,
    //
    required this.pte,
    required this.pteOn,
  });

  final int type;
  //
  final String deviceModel;
  int deviceModelOn;
  //
  final int msrunit;
  //
  final List<int> distances;
  final List<int> times;
  List<int> paces;
  final int avgPace;
  final int minPace;
  List<int> speeds;
  final int avgSpeed;
  final int maxSpeed;
  int pacesOn;
  int speedsOn;
  //
  List<int> heartRates;
  final int avgHeartRate;
  final int maxHeartRate;
  int heartRatesOn;
  //
  List<int> cadences;
  final int avgCadence;
  final int maxCadence;
  int cadencesOn;
  //
  List<int> altitudes;
  final int totalAscent;
  final int totalDescent;
  //
  List<int> powers;
  final int avgPower;
  final int maxPower;
  int powersOn;
  //
  List<int> respRates;
  final double avgRespRate;
  final double maxRespRate;
  final double minRespRate;
  int respRatesOn;
  //
  final int calories;
  //
  final double effectAerobic;
  final double effectAnaerobic;
  int teOn;
  //
  final double pte;
  int pteOn;

  // --

  bool get isEmpty {
    return distances.isEmpty && times.isEmpty;
  }

  bool get isPower => avgPower != 0;
  bool get isHeartRate => avgHeartRate != 0;
  bool get isCadence => avgCadence != 0;
  bool get isRespRate => avgRespRate != 0;
  bool get isAltitude => totalAscent != 0 && totalDescent != 0;
  bool get isTE => effectAerobic != 0 || effectAnaerobic != 0;
  bool get isPTE => pte != 0;

  bool get isPacesOn => pacesOn == 1;
  bool get isSpeedsOn => speedsOn == 1;

  bool get isPowerOn => avgPower != 0 && powersOn == 1;
  bool get isHeartRateOn => avgHeartRate != 0 && heartRatesOn == 1;
  bool get isCadenceOn => avgCadence != 0 && cadencesOn == 1;
  bool get isRespRateOn => avgRespRate != 0 && respRatesOn == 1;
  bool get isTEOn => effectAerobic != 0 || effectAnaerobic != 0 && teOn == 1;
  bool get isPTEOn => pte != 0 && pteOn == 1;

  factory TrailDeviceData.fromJson(Map<String, dynamic> json) {
    final String deviceModel = fnParseDeviceModelIncr(
      json['device_model'] ?? '',
    );

    return TrailDeviceData(
      type: json['type'] ?? 1,
      //
      deviceModel: deviceModel,
      deviceModelOn: json['device_model_on'] ?? 2,
      //
      msrunit: json['msrunit'] ?? 1,
      //
      distances: List<int>.from(json['distances'] ?? []),
      times: List<int>.from(json['times'] ?? []),
      paces: List<int>.from(json['paces'] ?? []),
      avgPace: json['avg_pace'] ?? 0,
      minPace: json['min_pace'] ?? 0,
      speeds: List<int>.from(json['speeds'] ?? []),
      avgSpeed: json['avg_speed'] ?? 0,
      maxSpeed: json['max_speed'] ?? 0,
      pacesOn: json['paces_on'] ?? 1,
      speedsOn: json['speeds_on'] ?? 1,
      //
      heartRates: List<int>.from(json['heart_rates'] ?? []),
      avgHeartRate: json['avg_heart_rate'] ?? 0,
      maxHeartRate: json['max_heart_rate'] ?? 0,
      heartRatesOn: json['heart_rates_on'] ?? 1,
      //
      cadences: List<int>.from(json['cadences'] ?? []),
      avgCadence: json['avg_cadence'] ?? 0,
      maxCadence: json['max_cadence'] ?? 0,
      cadencesOn: json['cadences_on'] ?? 1,
      //
      altitudes: List<int>.from(json['altitudes'] ?? []),
      totalAscent: json['total_ascent'] ?? 0,
      totalDescent: json['total_descent'] ?? 0,
      //
      powers: List<int>.from(json['powers'] ?? []),
      avgPower: json['avg_power'] ?? 0,
      maxPower: json['max_power'] ?? 0,
      powersOn: json['powers_on'] ?? 1,
      //
      respRates: List<int>.from(json['resp_rates'] ?? []),
      avgRespRate: (json['avg_resp_rate'] ?? 0.0) + 0.0,
      maxRespRate: (json['max_resp_rate'] ?? 0.0) + 0.0,
      minRespRate: (json['min_resp_rate'] ?? 0.0) + 0.0,
      respRatesOn: json['resp_rates_on'] ?? 1,
      //
      calories: json['calories'] ?? 0,
      //
      effectAerobic: (json['effect_aerobic'] ?? 0.0) + 0.0,
      effectAnaerobic: (json['effect_anaerobic'] ?? 0.0) + 0.0,
      teOn: json['te_on'] ?? 1,
      //
      pte: (json['pte'] ?? 0.0) + 0.0,
      pteOn: json['pte_on'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'device_model': deviceModel,
      'device_model_on': deviceModelOn,
      //
      'msrunit': msrunit,
      //
      'distances': distances,
      'times': times,
      'paces': paces,
      'avg_pace': avgPace,
      'min_pace': minPace,
      'speeds': speeds,
      'avg_speed': avgSpeed,
      'max_speed': maxSpeed,
      'paces_on': pacesOn,
      'speeds_on': speedsOn,
      //
      'heart_rates': heartRates,
      'avg_heart_rate': avgHeartRate,
      'max_heart_rate': maxHeartRate,
      'heart_rates_on': heartRatesOn,
      //
      'cadences': cadences,
      'avg_cadence': avgCadence,
      'max_cadence': maxCadence,
      'cadences_on': cadencesOn,
      //
      'altitudes': altitudes,
      'total_ascent': totalAscent,
      'total_descent': totalDescent,
      //
      'powers': powers,
      'avg_power': avgPower,
      'max_power': maxPower,
      'powers_on': powersOn,
      //
      'resp_rates': respRates,
      'avg_resp_rate': avgRespRate,
      'max_resp_rate': maxRespRate,
      'min_resp_rate': minRespRate,
      'resp_rates_on': respRatesOn,
      //
      'calories': calories,
      //
      'effect_aerobic': effectAerobic,
      'effect_anaerobic': effectAnaerobic,
      'te_on': teOn,
      //
      'pte': pte,
      'pte_on': pteOn,
    };
  }

  factory TrailDeviceData.empty() {
    return TrailDeviceData.fromJson({
      'type': 1,
      'device_model': '',
      'device_model_on': 0,
      //
      'msrunit': 1,
      //
      'distances': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      'times': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      'paces': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      'avg_pace': 0,
      'min_pace': 0,
      'speeds': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      'avg_speed': 0,
      'max_speed': 0,
      'paces_on': 0,
      'speeds_on': 0,
      //
      'heart_rates': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      'avg_heart_rate': 0,
      'max_heart_rate': 0,
      'heart_rates_on': 0,
      //
      'cadences': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      'avg_cadence': 0,
      'max_cadence': 0,
      //
      'altitudes': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      'total_ascent': 0,
      'total_descent': 0,
      //
      'powers': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      'avg_power': 0,
      'max_power': 0,
      'powers_on': 0,
      //
      'resp_rates': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      'avg_resp_rate': 0.0,
      'max_resp_rate': 0.0,
      'min_resp_rate': 0.0,
      'resp_rates_on': 0,
      //
      'calories': 0,
      //
      'effect_aerobic': 0.0,
      'effect_anaerobic': 0.0,
      'te_on': 0,
      //
      'pte': 0.0,
      'pte_on': 0,
    });
  }
}

class TrailGraphData {
  static const String kDeviceModel = 'device_model';
  static const String kDistances = 'distances';
  static const String kTimes = 'times';

  // can be on card
  static const String kPaces = 'paces';
  static const String kSpeeds = 'speeds';

  // others
  static const String kHeartRates = 'heart_rates';
  static const String kAltitudes = 'altitudes';
  static const String kCadences = 'cadences';
  static const String kPowers = 'powers';
  static const String kRespRates = 'resp_rates';
  static const String kTrainingEff = 'training_eff';
  static const String kPeakTrainingEff = 'peak_training_eff';
  static const String kCalories = 'calories';

  static String formatKeyToStr(String key) {
    if (key == TrailGraphData.kSpeeds) return 'Speed';
    if (key == TrailGraphData.kPaces) return 'Pace';
    if (key == TrailGraphData.kHeartRates) return 'Heart Rate';
    if (key == TrailGraphData.kAltitudes) return 'Elevation';
    if (key == TrailGraphData.kCadences) return 'Cadence';
    if (key == TrailGraphData.kPowers) return 'Power';
    if (key == TrailGraphData.kRespRates) return 'Respiration Rate';
    if (key == TrailGraphData.kTrainingEff) return 'Training Effect';
    if (key == TrailGraphData.kPeakTrainingEff) return 'Peak Training Effect';
    if (key == TrailGraphData.kCalories) return 'Calories';

    return 'Unknown';
  }

  const TrailGraphData({
    required this.type,
    //
    required this.key,
    required this.msrunit0,
    required this.msrunit,
    required this.suff,
    //
    required this.labelLeft,
    required this.valueLeft,
    //
    this.labelCenter,
    this.valueCenter,
    //
    required this.labelRight,
    required this.valueRight,
    //
    required this.graphDataVal,
    required this.graphDataDist,
    required this.graphDataTime,
    //
    required this.graphColorMain,
    required this.graphColorBack,
  });

  final int type;

  final String key;
  final int msrunit0;
  final int msrunit;
  final String suff;

  final String labelLeft;
  final String valueLeft;

  final String? labelCenter;
  final String? valueCenter;

  final String labelRight;
  final String valueRight;

  final List<int> graphDataVal;
  final List<int> graphDataDist;
  final List<int> graphDataTime;

  final Color graphColorMain;
  final Color graphColorBack;

  static Map<String, TrailGraphData> buildGraphsData({
    required TrailDeviceData deviceData,
    required int msrunit,
  }) {
    List<int> distancesAv = List<int>.from(fnBuildAdaptiv(
      deviceData.distances,
      msrunit,
    ));
    distancesAv = distancesAv.map((dst) {
      if (msrunit == UserMeasurementUnit.km) {
        return (dst / 1000 * 100).toInt();
      } else {
        return (dst * 0.0006213712 * 10).toInt();
      }
    }).toList();

    List<int> timesAv = List<int>.from(fnBuildAdaptiv(
      deviceData.times,
      msrunit,
    ));

    if (deviceData.paces.isEmpty) {
      deviceData.paces = List<int>.filled(deviceData.distances.length, 0);
    }

    if (deviceData.speeds.isEmpty) {
      deviceData.speeds = List<int>.filled(deviceData.distances.length, 0);
    }

    if (deviceData.heartRates.isEmpty) {
      deviceData.heartRates = List<int>.filled(deviceData.distances.length, 0);
    }

    if (deviceData.altitudes.isEmpty) {
      deviceData.altitudes = List<int>.filled(deviceData.distances.length, 0);
    }

    if (deviceData.cadences.isEmpty) {
      deviceData.cadences = List<int>.filled(deviceData.distances.length, 0);
    }

    if (deviceData.powers.isEmpty) {
      deviceData.powers = List<int>.filled(deviceData.distances.length, 0);
    }

    if (deviceData.respRates.isEmpty) {
      deviceData.respRates = List<int>.filled(deviceData.distances.length, 0);
    }

    List<int> pacesAv = List<int>.from(fnBuildAdaptiv(
      deviceData.paces,
      msrunit,
      avg: true,
    ));

    List<int> speedsAv = List<int>.from(fnBuildAdaptiv(
      deviceData.speeds,
      msrunit,
      avg: true,
    ));

    List<int> heartRatesAv = List<int>.from(fnBuildAdaptiv(
      deviceData.heartRates,
      msrunit,
    ));

    List<int> altitudesAv = List<int>.from(fnBuildAdaptiv(
      deviceData.altitudes,
      msrunit,
    ));

    List<int> cadencesAv = List<int>.from(fnBuildAdaptiv(
      deviceData.cadences,
      msrunit,
    ));

    List<int> powersAv = List<int>.from(fnBuildAdaptiv(
      deviceData.powers,
      msrunit,
    ));

    List<int> respRatesAv = List<int>.from(fnBuildAdaptiv(
      deviceData.respRates,
      msrunit,
    ));

    List<int>? inxs;
    if (distancesAv.length > 10) {
      inxs = fnGenAdaptivLimit(distancesAv.length);
    }

    if (inxs != null) {
      distancesAv = fnFilterAdaptivLimit(distancesAv, inxs);
      timesAv = fnFilterAdaptivLimit(timesAv, inxs);
      pacesAv = fnFilterAdaptivLimit(pacesAv, inxs);
      speedsAv = fnFilterAdaptivLimit(speedsAv, inxs);
      heartRatesAv = fnFilterAdaptivLimit(heartRatesAv, inxs);
      altitudesAv = fnFilterAdaptivLimit(altitudesAv, inxs);
      cadencesAv = fnFilterAdaptivLimit(cadencesAv, inxs);
      powersAv = fnFilterAdaptivLimit(powersAv, inxs);
      respRatesAv = fnFilterAdaptivLimit(respRatesAv, inxs);
    }

    final vSpeeds = TrailGraphData(
      type: deviceData.type,
      key: TrailGraphData.kSpeeds,
      msrunit0: deviceData.msrunit,
      msrunit: msrunit,
      labelLeft: 'Average',
      valueLeft: fnTimeExt(
        fnParseSpeedSec(deviceData.avgSpeed, msrunit),
        zero1th: false,
      ),
      suff: UserMeasurementUnit.formatPh(msrunit),
      labelRight: 'Best',
      valueRight: fnTimeExt(
        fnParseSpeedSec(deviceData.maxSpeed, msrunit),
        zero1th: false,
      ),
      graphDataVal: speedsAv,
      graphDataDist: distancesAv,
      graphDataTime: timesAv,
      graphColorMain: AppTheme.clYellow,
      graphColorBack: AppTheme.clYellow005,
    );

    final vPaces = TrailGraphData(
      type: deviceData.type,
      key: TrailGraphData.kPaces,
      msrunit0: deviceData.msrunit,
      msrunit: msrunit,
      labelLeft: 'Average',
      valueLeft: fnTimeExt(
        fnParsePaceSec(deviceData.avgPace, msrunit),
        zero1th: false,
      ),
      suff: '/${UserMeasurementUnit.format(msrunit)}',
      labelRight: 'Best',
      valueRight: fnTimeExt(
        fnParsePaceSec(deviceData.minPace, msrunit),
        zero1th: false,
      ),
      graphDataVal: pacesAv,
      graphDataDist: distancesAv,
      graphDataTime: timesAv,
      graphColorMain: AppTheme.clYellow,
      graphColorBack: AppTheme.clYellow005,
    );

    final vHeartRates = TrailGraphData(
      type: deviceData.type,
      key: TrailGraphData.kHeartRates,
      msrunit0: deviceData.msrunit,
      msrunit: msrunit,
      labelLeft: 'Average',
      valueLeft: deviceData.avgHeartRate.toString(),
      suff: 'bpm',
      labelRight: 'Maximum',
      valueRight: deviceData.maxHeartRate.toString(),
      graphDataVal: heartRatesAv,
      graphDataDist: distancesAv,
      graphDataTime: timesAv,
      graphColorMain: AppTheme.clText,
      graphColorBack: AppTheme.clText005,
    );

    final vAltitudes = TrailGraphData(
      type: deviceData.type,
      key: TrailGraphData.kAltitudes,
      msrunit0: deviceData.msrunit,
      msrunit: msrunit,
      labelLeft: 'Ascent',
      valueLeft: deviceData.totalAscent.toString(),
      suff: 'm',
      labelRight: 'Descent',
      valueRight: deviceData.totalDescent.toString(),
      graphDataVal: altitudesAv,
      graphDataDist: distancesAv,
      graphDataTime: timesAv,
      graphColorMain: Colors.pink,
      graphColorBack: Colors.pink.withOpacity(0.05),
    );

    final vCadences = TrailGraphData(
      type: deviceData.type,
      key: TrailGraphData.kCadences,
      msrunit0: deviceData.msrunit,
      msrunit: msrunit,
      labelLeft: 'Average',
      valueLeft: deviceData.avgCadence.toString(),
      suff: deviceData.type == TrailType.bike ? 'rpm' : 'spm',
      labelRight: 'Maximum',
      valueRight: deviceData.maxCadence.toString(),
      graphDataVal: cadencesAv,
      graphDataDist: distancesAv,
      graphDataTime: timesAv,
      graphColorMain: Colors.green,
      graphColorBack: Colors.green.withOpacity(0.05),
    );

    final vPowers = TrailGraphData(
      type: deviceData.type,
      key: TrailGraphData.kPowers,
      msrunit0: deviceData.msrunit,
      msrunit: msrunit,
      labelLeft: 'Average',
      valueLeft: deviceData.avgPower.toString(),
      suff: 'watt',
      labelRight: 'Maximum',
      valueRight: deviceData.maxPower.toString(),
      graphDataVal: powersAv,
      graphDataDist: distancesAv,
      graphDataTime: timesAv,
      graphColorMain: Colors.blue,
      graphColorBack: Colors.blue.withOpacity(0.05),
    );

    final vRespRates = TrailGraphData(
      type: deviceData.type,
      key: TrailGraphData.kRespRates,
      msrunit0: deviceData.msrunit,
      msrunit: msrunit,
      labelLeft: 'Average',
      valueLeft: deviceData.avgRespRate.toInt().toString(),
      suff: 'brpm',
      labelRight: 'Maximum',
      valueRight: deviceData.maxRespRate.toInt().toString(),
      graphDataVal: respRatesAv,
      graphDataDist: distancesAv,
      graphDataTime: timesAv,
      graphColorMain: Colors.lime,
      graphColorBack: Colors.lime.withOpacity(0.05),
    );

    final vTrainingEff = TrailGraphData(
      type: deviceData.type,
      key: TrailGraphData.kTrainingEff,
      msrunit0: deviceData.msrunit,
      msrunit: 0,
      labelLeft: 'Aerobic',
      valueLeft: deviceData.effectAerobic.toStringAsFixed(1),
      suff: '',
      labelRight: 'Anaerobic',
      valueRight: deviceData.effectAnaerobic.toStringAsFixed(1),
      graphDataVal: [],
      graphDataDist: [],
      graphDataTime: [],
      graphColorMain: Colors.transparent,
      graphColorBack: Colors.transparent,
    );

    String peStatus = 'Unknown';
    if (deviceData.pte < 1) {
      peStatus = 'No effect';
    } else if (deviceData.pte < 2) {
      peStatus = 'Minor effect';
    } else if (deviceData.pte < 3) {
      peStatus = 'Maintaining';
    } else if (deviceData.pte < 4) {
      peStatus = 'Improving';
    } else if (deviceData.pte < 5) {
      peStatus = 'Highly Improving';
    } else if (deviceData.pte >= 5) {
      peStatus = 'Overloading';
    }

    final vPeakTrainingEff = TrailGraphData(
      type: deviceData.type,
      key: TrailGraphData.kPeakTrainingEff,
      msrunit0: deviceData.msrunit,
      msrunit: 0,
      labelLeft: 'PTE',
      valueLeft: deviceData.pte.toStringAsFixed(1),
      suff: '',
      labelRight: 'Status',
      valueRight: peStatus,
      graphDataVal: [],
      graphDataDist: [],
      graphDataTime: [],
      graphColorMain: Colors.transparent,
      graphColorBack: Colors.transparent,
    );

    final vCalories = TrailGraphData(
      type: deviceData.type,
      key: TrailGraphData.kCalories,
      msrunit0: deviceData.msrunit,
      msrunit: 0,
      labelLeft: 'Total Calories',
      valueLeft: deviceData.calories.toString(),
      suff: 'kcal',
      labelRight: '',
      valueRight: '',
      graphDataVal: [],
      graphDataDist: [],
      graphDataTime: [],
      graphColorMain: Colors.transparent,
      graphColorBack: Colors.transparent,
    );

    // kcal

    return {
      TrailGraphData.kSpeeds: vSpeeds,
      TrailGraphData.kPaces: vPaces,
      TrailGraphData.kHeartRates: vHeartRates,
      TrailGraphData.kAltitudes: vAltitudes,
      TrailGraphData.kCadences: vCadences,
      TrailGraphData.kPowers: vPowers,
      TrailGraphData.kRespRates: vRespRates,
      TrailGraphData.kTrainingEff: vTrainingEff,
      TrailGraphData.kPeakTrainingEff: vPeakTrainingEff,
      TrailGraphData.kCalories: vCalories,
    };
  }
}
