// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:math';

import 'package:collection/collection.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/models/device_model.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/services/supabase_service.dart';
import 'package:trailcatch/utils/core_utils.dart';

//+ fit

Future<TrailModel?> fnParseFitData({
  required List<int> bytes,
  int? deviceId,
  bool fitFile = false,
}) async {
  final error = AppError(message: 'Error FIT', code: AppErrorCode.fitParse);

  final res0 = await supabase.functions.invoke(
    'garmin_fit',
    body: {
      "data": bytes,
    },
  );

  if (res0.data == null) throw error;

  Map<String, dynamic> fitData = res0.data;

  if (fitData['fileIdMesgs'] == null || fitData['fileIdMesgs'].length == 0) {
    throw error;
  }

  if (fitData['sessionMesgs'] == null || fitData['sessionMesgs'].length == 0) {
    throw error;
  }

  if (fitData['recordMesgs'] == null || fitData['recordMesgs'].length == 0) {
    throw error;
  }

  //+ fileIdMesgs

  final Map<String, dynamic> idMsgs = fitData['fileIdMesgs'][0];

  String deviceBrand = idMsgs['manufacturer'] ?? '';
  deviceBrand = deviceBrand.toTitle();

  int deviceId0 = deviceId ?? DeviceId.formatToId(deviceBrand) ?? 0;
  if (deviceId0 == 0) throw error;

  String deviceModel = '';
  if (idMsgs['garminProduct'] != null) {
    deviceModel = idMsgs['garminProduct'] ?? '';
    deviceModel = deviceModel.toTitle();
  } else if (idMsgs['productName'] != null) {
    deviceModel = idMsgs['productName'] ?? '';
    if (deviceModel.startsWith(deviceBrand)) {
      deviceModel = deviceModel.replaceAll(deviceBrand, '').trim();
    }

    deviceModel = deviceModel.toTitle();
    deviceModel = fnParseDeviceModelIncr(deviceModel);
  }

  //+ sessionMesgs

  final Map<String, dynamic> sesMsgs = fitData['sessionMesgs'][0];

  if (sesMsgs['sport'] == 'swimming') throw error;

  int type = 0;
  if (sesMsgs['sport'] == 'cycling') {
    type = TrailType.bike;
  } else if (sesMsgs['sport'] == 'running') {
    type = TrailType.run;
  } else {
    type = TrailType.walk;
  }

  final String datetimeAt = sesMsgs['startTime'];
  final String deviceDataIdHash = datetimeAt
      .replaceAll(' ', 'T')
      .replaceAll('-', '')
      .replaceAll(':', '')
      .replaceAll('+00', '')
      .replaceAll('.000Z', '.')
      .replaceAll('.', '');

  final int distance = (sesMsgs['totalDistance'])?.toInt() ?? 0;
  final int time = (sesMsgs['totalTimerTime'])?.toInt() ?? 0;
  final int totalAscent = sesMsgs['totalAscent'] ?? 0;
  final int totalDescent = sesMsgs['totalDescent'] ?? 0;
  final int calories = sesMsgs['totalCalories'] ?? 0;
  final int avgSpeed = ((sesMsgs['enhancedAvgSpeed'] ?? 0.0) * 100).toInt();
  final int maxSpeed = ((sesMsgs['enhancedMaxSpeed'] ?? 0.0) * 100).toInt();
  final int avgHeartRate = sesMsgs['avgHeartRate'] ?? 0;
  final int maxHeartRate = sesMsgs['maxHeartRate'] ?? 0;
  final int avgPower = sesMsgs['avgPower'] ?? 0;
  final int maxPower = sesMsgs['maxPower'] ?? 0;

  final int cadDl = type == TrailType.bike ? 1 : 2;

  final double avgFracCadence = (sesMsgs['avgFractionalCadence'] ?? 0.0) + 0.0;
  final int avgCadence0 = sesMsgs['avgCadence'] ?? 0;
  final int avgCadence = ((avgCadence0 + avgFracCadence) * cadDl).toInt();

  final double maxFracCadence = (sesMsgs['maxFractionalCadence'] ?? 0.0) + 0.0;
  final int maxCadence0 = sesMsgs['maxCadence'] ?? 0;
  final int maxCadence = ((maxCadence0 + maxFracCadence) * cadDl).toInt();

  final double avgRespRate =
      (sesMsgs['enhancedAvgRespirationRate'] ?? 0.0) + 0.0;
  final double maxRespRate =
      (sesMsgs['enhancedMaxRespirationRate'] ?? 0.0) + 0.0;
  final double minRespRate =
      (sesMsgs['enhancedMinRespirationRate'] ?? 0.0) + 0.0;

  double effectAerobic = 0.0;
  double effectAnaerobic = 0.0;
  double pte = 0.0;

  if (deviceId0 == DeviceId.suunto) {
    pte = (sesMsgs['totalTrainingEffect'] ?? 0.0) + 0.0;
  } else {
    effectAerobic = (sesMsgs['totalTrainingEffect'] ?? 0.0) + 0.0;
    effectAnaerobic = (sesMsgs['totalAnaerobicTrainingEffect'] ?? 0.0) + 0.0;
  }

  //+ recordMesgs

  final List<Map<String, dynamic>> recordMesgs =
      List<Map<String, dynamic>>.from(
    fitData['recordMesgs'],
  );

  final int pdll = distance > 1000 ? 500 : 100;

  int pdl = 0;
  List<Map<String, dynamic>> points = [];
  for (var point in recordMesgs) {
    if (points.isEmpty) {
      points.add(point);
      pdl += pdll;
      continue;
    } else {
      if ((point['distance'] ?? 0) > pdl) {
        pdl += pdll;
        points.add(point);
      } else if (recordMesgs.last == point) {
        points.add(point);
      }
    }
  }

  final List<LatLng> geoPoints = [];
  final List<int> distances = [];
  final List<int> times = [];
  final List<int> paces = [];
  final List<int> speeds = [];
  final List<int> heartRates = [];
  final List<int> cadences = [];
  final List<int> altitudes = [];
  final List<int> powers = [];
  final List<int> respRates = [];

  for (var p0 in points) {
    final inx = points.indexOf(p0);

    final dist0 = (p0['distance'] as num? ?? 0).toInt();
    distances.add(dist0);

    if (geoPoints.isEmpty && distance > 200) {
      if (p0['positionLat'] != null) {
        geoPoints.add(LatLng.fromSemicircles(
          p0['positionLat'],
          p0['positionLong'],
        ));
      }
    } else if (distance > 200 && distance - 200 < dist0 && inx != 0) {
      if (points[inx - 1]['positionLat'] != null) {
        geoPoints.add(LatLng.fromSemicircles(
          points[inx - 1]['positionLat'],
          points[inx - 1]['positionLong'],
        ));
      }
    }

    if (inx == 0) {
      times.add(0);
      paces.add(0);
    } else {
      final dt0 = DateTime.parse(points[0]['timestamp']);
      final preDt = DateTime.parse(points[inx - 1]['timestamp']);
      final dt = DateTime.parse(p0['timestamp']);

      times.add(dt.difference(dt0).inSeconds);
      paces.add((dt.difference(preDt).inSeconds / pdll * 100).toInt());
    }

    speeds.add(((p0['enhancedSpeed'] ?? 0.0) * 100).toInt());
    heartRates.add((p0['heartRate'] ?? 0).toInt());
    cadences.add(((p0['cadence'] ?? 0) * cadDl).toInt());
    altitudes.add((p0['enhancedAltitude'] ?? 0.0).toInt());

    powers.add(p0['power'] ?? 0);
    respRates.add((p0['enhancedRespirationRate'] ?? 0).toInt());
  }

  if (points.length >= 3 && geoPoints.length == 2) {
    final centerInx = fnMiddleIndex(List<int>.generate(
      points.length,
      (i) => i,
      growable: true,
    ));

    if (centerInx != -1) {
      if (points[centerInx]['positionLat'] != null) {
        geoPoints.add(LatLng.fromSemicircles(
          points[centerInx]['positionLat'],
          points[centerInx]['positionLong'],
        ));
      }
    }
  }

  final int minPace = paces.where((p) => p != 0).toList().min.toInt();
  int avgPace = 0;

  final ppaces = List<int>.from(paces).where((p) => p != 0).toList();
  if (ppaces.length >= 2) {
    ppaces.removeLast();
    avgPace = ppaces.average.toInt();
  } else {
    final pppaces = paces.where((p) => p != 0).toList();
    if (pppaces.isNotEmpty) {
      avgPace = pppaces.average.toInt();
    }
  }

  String deviceDataId = 'tc_${deviceId0}__$deviceDataIdHash';
  if (fitFile) {
    deviceDataId += 'f';
  }

  final Map<String, dynamic> json = {
    'trail_id': '',
    'user_id': '',
    'type': type,
    'datetime_at': datetimeAt,
    'distance': distance,
    'elevation': totalAscent,
    'time': time,
    'avg_pace': avgPace,
    'avg_speed': avgSpeed,
    'dogs_ids': [],
    'device': deviceId0,
    'device_data_id': deviceDataId,
    'device_data': {
      'device_model': deviceModel,
      'device_model_on': 2,
      'msrunit': 1,
      'distances': distances,
      'times': times,
      'paces': paces,
      'avg_pace': avgPace,
      'min_pace': minPace,
      'speeds': speeds,
      'avg_speed': avgSpeed,
      'max_speed': maxSpeed,
      'paces_on': 1,
      'speeds_on': 1,
      'heart_rates': heartRates,
      'avg_heart_rate': avgHeartRate,
      'max_heart_rate': maxHeartRate,
      'heart_rates_on': avgHeartRate != 0 || maxHeartRate != 0 ? 1 : 0,
      'cadences': cadences,
      'avg_cadence': avgCadence,
      'max_cadence': maxCadence,
      'cadences_on': avgCadence != 0 || maxCadence != 0 ? 1 : 0,
      'altitudes': altitudes,
      'total_ascent': totalAscent,
      'total_descent': totalDescent,
      'powers': powers,
      'avg_power': avgPower,
      'max_power': maxPower,
      'powers_on': avgPower != 0 || maxPower != 0 ? 1 : 0,
      'resp_rates': respRates,
      'avg_resp_rate': avgRespRate,
      'max_resp_rate': maxRespRate,
      'min_resp_rate': minRespRate,
      'resp_rates_on': avgRespRate != 0 || maxRespRate != 0 ? 1 : 0,
      'calories': calories,
      'effect_aerobic': effectAerobic,
      'effect_anaerobic': effectAnaerobic,
      'te_on': effectAerobic != 0 || effectAnaerobic != 0 ? 1 : 0,
      'pte': pte,
      'pte_on': pte != 0 ? 1 : 0,
    },
    'device_geopoints': LatLng.toPGMultiPointSRID(geoPoints),
    'intrash': false,
    'notpub': false,
    'pub_at': null,
    'created_at': null,
  };

  return TrailModel.fromJson(json);
}

List<num> fnBuildAdaptiv(
  List<num> list,
  int msrunit, {
  bool avg = false,
}) {
  List<List<num>> llist0 = [[]];
  List<num> llist = [];

  int dl = msrunit == UserMeasurementUnit.km ? 2 : 3;

  int inx = -1;
  for (var p in list) {
    inx += 1;

    if (inx == 0) continue;

    if (llist0.last.isEmpty) {
      llist0.last.add(p);
    } else if (llist0.last.length != dl) {
      llist0.last.add(p);
    } else if (llist0.last.length == dl) {
      llist0.add([p]);
    }
  }

  for (var p0 in llist0) {
    if (p0.length > 1) {
      if (avg) {
        llist.add(p0.average.toInt());
      } else {
        llist.add(p0.last);
      }
    } else if (p0.length == 1) {
      llist.add(p0.first);
    }
  }

  return llist;
}

List<int> fnGenAdaptivLimit(int length) {
  Random random = Random();

  List<int> rinxs = [];
  List<int> allinxs = List.generate(
    length,
    (i) => i,
    growable: true,
  );

  rinxs.add(allinxs.removeAt(0));
  final int last = allinxs.removeLast();

  for (var _ in List.filled(8, 0)) {
    int rinx = random.nextInt(allinxs.length);
    rinxs.add(allinxs.removeAt(rinx));
  }

  rinxs.add(last);
  rinxs.sort();

  return rinxs;
}

List<T> fnFilterAdaptivLimit<T>(List<T> list, List<int> inxs) {
  List<T> list0 = [];

  for (var inx in inxs) {
    list0.add(list.elementAt(inx));
  }

  return list0;
}
