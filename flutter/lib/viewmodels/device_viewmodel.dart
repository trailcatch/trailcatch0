// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/device_model.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/device_utils.dart';
import 'package:trailcatch/viewmodels/base_viewmodel.dart';

class DeviceViewModel extends BaseViewModel {
  final Set<int> _connDeviceIds = {};
  List<int> get connDeviceIds => _connDeviceIds.toList();

  bool get isGarmin => _connDeviceIds.contains(DeviceId.garmin);
  bool get isSuunto => _connDeviceIds.contains(DeviceId.suunto);
  bool get isPolar => _connDeviceIds.contains(DeviceId.polar);
  bool isDevice(int deviceId) => _connDeviceIds.contains(deviceId);

  int? _syncedTrailsCount;
  int? get syncedTrailsCount => _syncedTrailsCount;
  int? _syncedTrails;
  int? get syncedTrails => _syncedTrails;
  bool stopTrailsSync = false;

  Future<void> reInit() async {
    _connDeviceIds.addAll([
      if (await devGarminServ.pingGarmin()) DeviceId.garmin,
      if (await devSuuntoServ.pingSuunto()) DeviceId.suunto,
      if (await devPolarServ.pingPolar()) DeviceId.polar,
    ]);
  }

  Future<void> reSyncDeviceTrails({
    required SyncDate syncDate,
    int? deviceId,
  }) async {
    stopTrailsSync = false;
    List<TrailExtModel> buffer = [];

    final List<int> deviceIds = deviceId == null ? DeviceId.all : [deviceId];
    for (var deviceId in deviceIds) {
      if (isDevice(deviceId)) {
        buffer.addAll(
          await syncDeviceTrails(
            deviceId: deviceId,
            syncDate: syncDate,
          ),
        );
      }
    }

    if (buffer.isNotEmpty) {
      trailVM.myTrailsExt.addAll(buffer);
      fnSortTrailsDateDesc(trailVM.myTrailsExt);

      trailVM.notify();
    }
  }

  //+ garmin

  Future<void> connGarmin() async {
    final bool isOk = await devGarminServ.connGarmin();
    if (isOk) {
      _connDeviceIds.add(DeviceId.garmin);

      notify();
    }
  }

  Future<void> disconnGarmin() async {
    await devGarminServ.disconnGarmin();
    _connDeviceIds.remove(DeviceId.garmin);

    notify();
  }

  //+ suunto

  Future<void> connSuunto() async {
    final bool isOk = await devSuuntoServ.connSuunto();
    if (isOk) {
      _connDeviceIds.add(DeviceId.suunto);

      notify();
    }
  }

  Future<void> disconnSuunto() async {
    await devSuuntoServ.disconnSuunto();
    _connDeviceIds.remove(DeviceId.suunto);

    notify();
  }

  //+ polar

  Future<void> connPolar() async {
    final bool isOk = await devPolarServ.connPolar();
    if (isOk) {
      _connDeviceIds.add(DeviceId.polar);

      notify();
    }
  }

  Future<void> disconnPolar() async {
    await devPolarServ.disconnPolar();
    _connDeviceIds.remove(DeviceId.polar);

    notify();
  }

//+ sync

  Future<List<TrailExtModel>> syncDeviceTrails({
    required int deviceId,
    required SyncDate syncDate,
  }) async {
    late final Function({required SyncDate syncDate}) syncDeviceDataIds;
    late final Function(String dataId) syncDeviceData;

    if (deviceId == DeviceId.garmin) {
      syncDeviceDataIds = devGarminServ.syncGarminDataIds;
      syncDeviceData = devGarminServ.syncGarminDeviceData;
    } else if (deviceId == DeviceId.suunto) {
      syncDeviceDataIds = devSuuntoServ.syncSuuntoDataIds;
      syncDeviceData = devSuuntoServ.syncSuuntoDeviceData;
    } else if (deviceId == DeviceId.polar) {
      syncDeviceDataIds = devPolarServ.syncPolarDataIds;
      syncDeviceData = devPolarServ.syncPolarDeviceData;
    }

    _syncedTrailsCount = null;
    _syncedTrails = null;

    final List<String> dataIds = await syncDeviceDataIds(syncDate: syncDate);

    _syncedTrailsCount = dataIds.length;
    _syncedTrails = 0;
    notify();

    final List<TrailExtModel> trails = [];

    for (var dataId in dataIds) {
      if (stopTrailsSync) {
        return trails;
      }

      TrailModel? trail;

      final List<int>? bytes = await syncDeviceData(dataId);
      if (bytes != null) {
        trail = await fnParseFitData(
          bytes: bytes,
          deviceId: deviceId,
        );
      }

      if (trail != null) {
        await Future.delayed(250.mlsec);

        final dbtrail = await trailServ.fnTrailsInsert(
          type: trail.type,
          datetimeAt: trail.datetimeAt,
          distance: trail.distance,
          elevation: trail.elevation,
          time: trail.time,
          //
          avgPace: trail.avgPace,
          avgSpeed: trail.avgSpeed,
          //
          dogsIds: trail.dogsIds,
          //
          deviceId: trail.deviceId,
          deviceDataId: trail.deviceDataId,
          deviceData: trail.deviceData?.toJson(),
          deviceGeopoints: LatLng.toPGMultiPointSRID(trail.deviceGeopoints),
        );

        if (dbtrail != null) {
          trails.add(TrailExtModel.fromTrail(dbtrail));
        }
      }

      if (_syncedTrails != null) {
        _syncedTrails = _syncedTrails! + 1;
        notify();
      }
    }

    return trails;
  }

  void clearSyncedCounts() {
    _syncedTrailsCount = null;
    _syncedTrails = null;
  }
}
