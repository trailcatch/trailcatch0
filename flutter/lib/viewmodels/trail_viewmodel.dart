// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:trailcatch/constants.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/viewmodels/base_viewmodel.dart';

class TrailViewModel extends BaseViewModel {
  late bool _loadingSkeletons;
  bool get loadingSkeletons => _loadingSkeletons;
  late bool _loadingTop;
  bool get loadingTop => _loadingTop;
  late bool _loadingBottom;
  bool get loadingBottom => _loadingBottom;

  TrailFilters _trailFilters = TrailFilters(
    genders: [],
    ageGroups: [],
    uiso3s: [],
    dogsBreed: [],
  );
  TrailFilters get trailFilters => _trailFilters;

  final List<TrailExtModel> _feedTrailsExt = [];
  List<TrailExtModel> get feedTrailsExt => _feedTrailsExt;

  final List<TrailExtModel> _feedFltTrailsExt = [];
  List<TrailExtModel> get feedFltTrailsExt => _feedFltTrailsExt;

  final List<TrailExtModel> _nearTrailsExt = [];
  List<TrailExtModel> get nearTrailsExt => _nearTrailsExt;

  final List<TrailExtModel> _myTrailsExt = [];
  List<TrailExtModel> get myTrailsExt => _myTrailsExt;
  void clearMyTrailsExt() => _myTrailsExt.clear();

  Set<String> get feedTrailsDataIds {
    return _feedTrailsExt.map((trl) => trl.trail.deviceDataId).toSet();
  }

  Set<String> get feedFltTrailsDataIds {
    return _feedFltTrailsExt.map((trl) => trl.trail.deviceDataId).toSet();
  }

  Set<String> get nearTrailsDataIds {
    return _nearTrailsExt.map((trl) => trl.trail.deviceDataId).toSet();
  }

  Set<String> get myTrailsDataIds {
    return _myTrailsExt.map((trl) => trl.trail.deviceDataId).toSet();
  }

  Future<void> Function() reFetchRadar0 = () async {};
  Future<void> Function() reFetchRlship0 = () async {};

  @override
  void notify({
    bool? loadingTop,
  }) {
    if (loadingTop != null) {
      _loadingTop = loadingTop;
    }

    super.notify();
  }

  Future<void> reInitTrails() async {
    if (!appVM.isUserExists) return;

    _loadingSkeletons = false;
    _loadingTop = false;
    _loadingBottom = false;

    _trailFilters = await TrailFilters.build();

    await Future.wait([
      reFetchFeedTrails(
        syncDate: const SyncDate(
          limit: cstFirstLoadItemCount,
        ),
        doClear: true,
      ),
      reFetchFltFeedTrails(
        syncDate: const SyncDate(
          limit: cstFirstLoadItemCount,
        ),
        doClear: true,
      ),
      reFetchNearestTrails(
        syncDate: const SyncDate(
          limit: cstFirstLoadNearItemCount,
        ),
        doClear: true,
      ),
    ]);
  }

  Future<void> reFetchFeedTrails({
    required SyncDate syncDate,
    bool? doClear,
  }) async {
    final feedTrailsExt0 = await trailServ.fnTrailsFetchFeeds(
      syncDate: syncDate,
    );

    if (doClear ?? false) {
      _feedTrailsExt.clear();
    }

    final feedTrailsDataIds0 = feedTrailsDataIds;
    for (var trl in feedTrailsExt0) {
      if (!feedTrailsDataIds0.contains(trl.trail.deviceDataId)) {
        _feedTrailsExt.add(trl);
      }
    }

    fnSortTrailsDateDesc(_feedTrailsExt);
  }

  Future<void> reFetchFltFeedTrails({
    required SyncDate syncDate,
    bool? doClear,
  }) async {
    if (trailFilters.isEmpty) {
      _feedFltTrailsExt.clear();
      return;
    }

    final feedFltTrailsExt0 = await trailServ.fnTrailsFetchFeeds(
      type: trailFilters.trailType,
      withDogs: trailFilters.withDogs,
      usersGenders: trailFilters.genders.toList(),
      usersAges: trailFilters.ageGroupsToInt(),
      usersUiso3: trailFilters.uiso3s,
      dogsBreed: trailFilters.dogsBreed.toList(),
      syncDate: syncDate,
    );

    if (doClear ?? false) {
      _feedFltTrailsExt.clear();
    }

    final feedFltTrailsDataIds0 = feedFltTrailsDataIds;
    for (var trlFlt in feedFltTrailsExt0) {
      if (!feedFltTrailsDataIds0.contains(trlFlt.trail.deviceDataId)) {
        _feedFltTrailsExt.add(trlFlt);
      }
    }

    fnSortTrailsDateDesc(_feedFltTrailsExt);
  }

  Future<void> reFetchNearestTrails({
    required SyncDate syncDate,
    bool? doClear,
  }) async {
    if (appVM.yourCity != null) {
      final nearTrailsExt0 = await trailServ.fnTrailsFetchNearest(
        geopoint: appVM.yourCity!.geopoint,
        type: trailFilters.trailType,
        withDogs: trailFilters.withDogs,
        usersGenders: trailFilters.genders.toList(),
        usersAges: trailFilters.ageGroupsToInt(),
        usersUiso3: trailFilters.uiso3s,
        dogsBreed: trailFilters.dogsBreed.toList(),
        strangesOnly: trailFilters.strangesOnly,
        syncDate: syncDate,
      );

      if (doClear ?? false) {
        _nearTrailsExt.clear();
      }

      final nearTrailsDataIds0 = nearTrailsDataIds;
      for (var trl in nearTrailsExt0) {
        if (!nearTrailsDataIds0.contains(trl.trail.deviceDataId)) {
          _nearTrailsExt.add(trl);
        }
      }
    } else {
      if (doClear ?? false) {
        _nearTrailsExt.clear();
      }
    }
  }

  Future<void> reFetchMyTrails({
    required SyncDate syncDate,
    int? trailType,
    bool? withDogs,
    int? deviceId,
  }) async {
    final myTrailsExt0 = await trailServ.fnTrailsFetch(
      userId: appVM.user.userId,
      type: trailType,
      withDogs: withDogs,
      deviceId: deviceId,
      syncDate: syncDate,
    );

    final myTrailsDataIds0 = myTrailsDataIds;
    for (var trl in myTrailsExt0) {
      if (!myTrailsDataIds0.contains(trl.trail.deviceDataId)) {
        _myTrailsExt.add(trl);
      }
    }

    fnSortTrailsDateDesc(_myTrailsExt);
  }

  List<String> lastTrailsNotPubIds() {
    final List<String> lasts = [];

    for (var myTrailExt in _myTrailsExt) {
      if (myTrailExt.trail.notPub) {
        final diffHours =
            DateTime.now().difference(myTrailExt.trail.datetimeAt).inHours;

        if (diffHours <= cstNotPubDiffHours) {
          lasts.add(myTrailExt.trail.trailId);
        }
      }
    }

    return lasts;
  }

  Future<void> trashTrails(List<TrailExtModel> trailsExt) async {
    final List<String> idsToTrash = [];

    for (var trailExt in trailsExt) {
      idsToTrash.add(trailExt.trail.trailId);

      trailExt.trail.inTrash = true;
      trailExt.trail.notPub = false;
    }

    for (var trl in _myTrailsExt) {
      if (idsToTrash.contains(trl.trail.trailId)) {
        trl.trail.inTrash = true;
        trl.trail.notPub = false;
      }
    }

    await trailServ.fnTrailsInTrash(trailIds: idsToTrash);
    trailVM.notify();
  }

  Future<void> trashBackTrail(TrailExtModel trailExt) async {
    trailExt.trail.inTrash = false;
    trailExt.trail.notPub = true;

    await updateTrail(trail: trailExt.trail);
    trailVM.notify();
  }

  Future<void> deleteTrail(TrailExtModel trailExt) async {
    await trailServ.fnTrailsDelete(trailId: trailExt.trail.trailId);

    trailVM.myTrailsExt.removeWhere(
      (trl) => trl.trail.trailId == trailExt.trail.trailId,
    );
    trailVM.nearTrailsExt.removeWhere(
      (trl) => trl.trail.trailId == trailExt.trail.trailId,
    );
    trailVM.feedFltTrailsExt.removeWhere(
      (trl) => trl.trail.trailId == trailExt.trail.trailId,
    );
    trailVM.feedTrailsExt.removeWhere(
      (trl) => trl.trail.trailId == trailExt.trail.trailId,
    );

    trailVM.notify();
  }

  Future<void> updateTrail({
    required TrailModel trail,
  }) async {
    await trailServ.fnTrailsUpdate(
      trailId: trail.trailId,
      type: trail.type,
      //
      avgPace: trail.avgPace,
      avgSpeed: trail.avgSpeed,
      //
      dogsIds: trail.dogsIds,
      //
      deviceData: trail.deviceData?.toJson(),
      deviceGeopoints: LatLng.toPGMultiPointSRID(trail.deviceGeopoints),
      //
      intrash: trail.inTrash,
      notPub: trail.notPub,
      pubAt: trail.pubAt,
    );
  }
}
