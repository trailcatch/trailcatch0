// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

abstract class DeviceId {
  static const int fit = 1;
  static const int garmin = 2;
  static const int suunto = 3;
  static const int polar = 4;

  static List<int> get all {
    return [
      DeviceId.garmin,
      DeviceId.suunto,
      DeviceId.polar,
    ];
  }

  static List<String> get allStr {
    return [
      'All Devices',
      'Garmin',
      'Suunto',
      'Polar',
    ];
  }

  static String formatToStr(int? deviceId) {
    if (deviceId == DeviceId.garmin) return 'Garmin';
    if (deviceId == DeviceId.suunto) return 'Suunto';
    if (deviceId == DeviceId.polar) return 'Polar';
    if (deviceId == DeviceId.fit) return '*.FIT';

    return 'All Devices';
  }

  static int? formatToId(String? deviceStr) {
    if (deviceStr == 'Garmin') return DeviceId.garmin;
    if (deviceStr == 'Suunto') return DeviceId.suunto;
    if (deviceStr == 'Polar') return DeviceId.polar;
    if (deviceStr == '*.FIT') return DeviceId.fit;

    return null;
  }
}
