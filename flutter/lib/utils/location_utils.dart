// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:math';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:geo_sort/geo_sort.dart';
import 'package:geodesy/geodesy.dart' as geodesy;
import 'package:trailcatch/constants.dart';

import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/location_model.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/utils/core_utils.dart';

Future<List<LocationModel>> fnLoadWorldCities() async {
  final String citiesStr = await rootBundle.loadString(
    'assets/***/worldcities.csv',
  );

  return const CsvToListConverter(
    fieldDelimiter: ';',
    shouldParseNumbers: false,
  ).convert(citiesStr).map((it) {
    return LocationModel(
      iso3: (it[4] as String).toLowerCase(),
      city: it[0],
      country: it[3],
      latitude: double.tryParse((it[1] as String).replaceAll(',', '.')) ?? 0.0,
      longitude: double.tryParse((it[2] as String).replaceAll(',', '.')) ?? 0.0,
    );
  }).toList();
}

List<List<dynamic>> fnBuildTrailDist8th(
  List<LatLng> point3th,
  double shakeDist,
) {
  final Map<String, List<dynamic>> direcEatch = {
    for (var der in cstRadarDers) der: [],
  };

  for (var point in point3th) {
    final List<LocationModel> cities8th = fnFindDist8th(point, shakeDist);

    for (var city8th in cities8th) {
      final double dist = fnFindDistMetric(
        point,
        LatLng(city8th.latitude, city8th.longitude),
      );

      final num bearing =
          geodesy.BearingBetweenTwoGeoPoints.bearingBetweenTwoGeoPoints(
        geodesy.LatLng(point.lat, point.lng),
        geodesy.LatLng(city8th.latitude, city8th.longitude),
      );

      String der = '';
      if (bearing >= 340 && bearing <= 360) {
        der = 'E';
      } else if (bearing >= 0 && bearing <= 20) {
        der = 'E';
      } else if (bearing > 20 && bearing < 70) {
        der = 'NE';
      } else if (bearing >= 70 && bearing <= 110) {
        der = 'N';
      } else if (bearing > 110 && bearing < 160) {
        der = 'NW';
      } else if (bearing >= 160 && bearing <= 200) {
        der = 'W';
      } else if (bearing > 200 && bearing < 250) {
        der = 'SW';
      } else if (bearing >= 250 && bearing <= 290) {
        der = 'S';
      } else if (bearing > 290 && bearing < 340) {
        der = 'SE';
      }

      direcEatch[der]!.add([city8th.city, dist]);
    }
  }

  final List<List<dynamic>> dist8th = [];
  final Set<String> usedCities = {};

  for (var derStr in cstRadarDers) {
    var der = (direcEatch[derStr] as List).toList();
    der.sort((a, b) => a.last.compareTo(b.last));
    der.removeWhere((d) => usedCities.contains(d.first));
    if (der.isEmpty) {
      dist8th.add(['', 0.0]);
    } else {
      der.removeWhere((d) => usedCities.contains(d.first));
      usedCities.add(der.first.first);

      int inx = Random().nextInt(der.length);
      dist8th.add(der[inx]);
    }
  }

  return dist8th;
}

List<LocationModel> fnFindDist8th(LatLng latLng, double radarMaxDist) {
  double maxDistance = radarMaxDist;
  if (appVM.settings.msrunit == UserMeasurementUnit.miles) {
    maxDistance = radarMaxDist * 1.60934;
  }

  return GeoSort.sortByLatLong(
    items: appVM.cities,
    latitude: latLng.lat,
    longitude: latLng.lng,
    ascending: true,
    maxDistance: maxDistance,
  );
}

double fnFindDistMetric(LatLng latLng1, LatLng latLng2) {
  return _getDistanceFromLatLonInMetric(
    latLng1.lat,
    latLng1.lng,
    latLng2.lat,
    latLng2.lng,
  );
}
