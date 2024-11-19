// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:geo_sort/geo_sort.dart';
import 'package:trailcatch/utils/core_utils.dart';

class LocationModel implements HasLocation {
  final String iso3;
  final String city;
  final String country;

  @override
  final double latitude;
  @override
  final double longitude;

  LatLng get geopoint => LatLng(latitude, longitude);

  LocationModel({
    required this.iso3,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
}
