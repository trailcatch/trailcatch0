// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/services/supabase_service.dart';
import 'package:trailcatch/utils/core_utils.dart';

class TrailService extends SupabaseService {
  Future<String?> fnTrailsExists({
    required String deviceDataId,
  }) async {
    return await callRPC(
      'tc_fn_trails_exists',
      params: {
        'f_device_data_id': deviceDataId,
      },
    );
  }

  Future<TrailModel?> fnTrailsInsert({
    int? type,
    DateTime? datetimeAt,
    int? distance,
    int? elevation,
    int? time,
    // --
    int? avgPace,
    int? avgSpeed,
    // --
    List<String>? dogsIds,
    // --
    int? deviceId,
    String? deviceDataId,
    Map<String, dynamic>? deviceData,
    String? deviceGeopoints,
  }) async {
    return await callRPC(
      'tc_fn_trails_insert',
      params: {
        'f_type': type,
        'f_datetime_at': datetimeAt?.toUtc().toIso8601String(),
        'f_distance': distance,
        'f_elevation': elevation,
        'f_time': time,
        // --
        'f_avg_pace': avgPace,
        'f_avg_speed': avgSpeed,
        // --
        'f_dogs_ids': dogsIds,
        // --
        'f_device': deviceId,
        'f_device_data_id': deviceDataId,
        'f_device_data': deviceData,
        'f_device_geopoints': deviceGeopoints,
      },
      fnJson: TrailModel.fromJson,
    );
  }

  Future<void> fnTrailsUpdate({
    required String trailId,
    required int type,
    // --
    int? avgPace,
    int? avgSpeed,
    // --
    List<String>? dogsIds,
    // --
    Map<String, dynamic>? deviceData,
    String? deviceGeopoints,
    // --
    required bool intrash,
    bool? notPub,
    DateTime? pubAt,
  }) async {
    await callRPC(
      'tc_fn_trails_update',
      params: {
        'f_trail_id': trailId,
        'f_type': type,
        // --
        'f_avg_pace': avgPace,
        'f_avg_speed': avgSpeed,
        // --
        'f_dogs_ids': dogsIds,
        // --
        'f_device_data': deviceData,
        'f_device_geopoints': deviceGeopoints,
        // --
        'f_intrash': intrash,
        'f_notpub': notPub,
        'f_pub_at': pubAt?.toUtc().toIso8601String(),
      },
    );
  }

  Future<void> fnTrailsInTrash({
    required List<String> trailIds,
  }) async {
    await callRPC<TrailExtModel>(
      'tc_fn_trails_intrash',
      params: {
        'f_trail_ids': trailIds,
      },
    );
  }

  Future<void> fnTrailsDelete({
    required String trailId,
  }) async {
    await callRPC<TrailExtModel>(
      'tc_fn_trails_delete',
      params: {
        'f_trail_id': trailId,
      },
    );
  }

  Future<List<TrailExtModel>> fnTrailsFetch({
    String? userId,
    String? trailId,
    int? deviceId,
    int? type,
    bool? withDogs,
    bool? inTrashNotPub,
    SyncDate? syncDate,
  }) async {
    final res = await callRPC<TrailExtModel>(
      'tc_fn_trails_fetch',
      params: {
        'f_user_id': userId,
        'f_trail_id': trailId,
        'f_device': deviceId,
        'f_type': type,
        'f_with_dogs': withDogs,
        'f_intrash_notpub': inTrashNotPub,
        'f_datetime_from': syncDate?.from?.toUtc().toIso8601String(),
        'f_datetime_to': syncDate?.to?.toUtc().toIso8601String(),
        'f_limit': syncDate?.limit,
      },
      fnJson: TrailExtModel.fromJson,
    );

    await storageServ.preDownloadTrailUUIDs(res);

    return res ?? [];
  }

  Future<List<TrailExtModel>> fnTrailsFetchFeeds({
    int? type,
    bool? withDogs,
    List<int>? usersGenders,
    List<int>? usersAges,
    List<String>? usersUiso3,
    List<int>? dogsBreed,
    SyncDate? syncDate,
  }) async {
    final res = await callRPC<TrailExtModel>(
      'tc_fn_trails_fetch_feed',
      params: {
        'f_type': type,
        'f_with_dogs': withDogs,
        'f_users_genders': usersGenders,
        'f_users_ages': usersAges,
        'f_users_uiso3': usersUiso3,
        'f_dogs_breed': dogsBreed?.map((it) => it.toString()).toList(),
        'f_datetime_from': syncDate?.from?.toUtc().toIso8601String(),
        'f_limit': syncDate?.limit,
      },
      fnJson: TrailExtModel.fromJson,
    );

    await storageServ.preDownloadTrailUUIDs(res);

    return res ?? [];
  }

  Future<List<TrailExtModel>> fnTrailsFetchSubscriptions({
    String? userId,
    bool? hiddens,
    SyncDate? syncDate,
  }) async {
    final res = await callRPC<TrailExtModel>(
      'tc_fn_trails_fetch_subscriptions',
      params: {
        'f_user_id': userId,
        'f_hiddens': hiddens,
        'f_datetime_from': syncDate?.from?.toUtc().toIso8601String(),
        'f_limit': syncDate?.limit,
      },
      fnJson: (Map<String, dynamic> json) => TrailExtModel.fromJson(
        json,
        skipNotPubAndInTrash: true,
      ),
    );

    await storageServ.preDownloadTrailUUIDs(res);

    return res ?? [];
  }

  Future<List<TrailExtModel>> fnTrailsFetchSubscribers({
    String? userId,
    SyncDate? syncDate,
  }) async {
    final res = await callRPC<TrailExtModel>(
      'tc_fn_trails_fetch_subscribers',
      params: {
        'f_user_id': userId,
        'f_datetime_from': syncDate?.from?.toUtc().toIso8601String(),
        'f_limit': syncDate?.limit,
      },
      fnJson: (Map<String, dynamic> json) => TrailExtModel.fromJson(
        json,
        skipNotPubAndInTrash: true,
      ),
    );

    await storageServ.preDownloadTrailUUIDs(res);

    return res ?? [];
  }

  Future<List<TrailExtModel>> fnTrailsFetchNearest({
    required LatLng geopoint,
    int? type,
    bool? withDogs,
    List<int>? usersGenders,
    List<int>? usersAges,
    List<String>? usersUiso3,
    List<int>? dogsBreed,
    bool? strangesOnly,
    SyncDate? syncDate,
  }) async {
    final res = await callRPC<TrailExtModel>(
      'tc_fn_trails_fetch_nearest',
      params: {
        'f_geopoint': LatLng.toPGMultiPointSRID([geopoint]),
        'f_type': type,
        'f_with_dogs': withDogs,
        'f_users_genders': usersGenders,
        'f_users_ages': usersAges,
        'f_users_uiso3': usersUiso3,
        'f_dogs_breed': dogsBreed?.map((it) => it.toString()).toList(),
        'f_stranges_only': strangesOnly,
        'f_offset': syncDate?.offset,
        'f_limit': syncDate?.limit,
      },
      fnJson: TrailExtModel.fromJson,
    );

    await storageServ.preDownloadTrailUUIDs(res);

    return res ?? [];
  }

  Future<List<TrailExtModel>> fnTrailsFetchPeople({
    SyncDate? syncDate,
    String? searchQ,
  }) async {
    final res = await callRPC<TrailExtModel>(
      'tc_fn_trails_fetch_people',
      params: {
        'f_offset': syncDate?.offset,
        'f_limit': syncDate?.limit,
        'f_search_q': searchQ,
      },
      fnJson: (Map<String, dynamic> json) => TrailExtModel.fromJson(
        json,
        skipNotPubAndInTrash: true,
      ),
    );

    await storageServ.preDownloadTrailUUIDs(res);

    return res ?? [];
  }

  Future<List<TrailExtModel>> fnTrailsLikesFetch({
    required String trailId,
    // --
    DateTime? likeCreatedAt,
    int? limit,
  }) async {
    final res = await callRPC<TrailExtModel>(
      'tc_fn_trails_likes_fetch',
      params: {
        'f_trail_id': trailId,
        // --
        'f_created_at': likeCreatedAt?.toUtc().toIso8601String(),
        'f_limit': limit,
      },
      fnJson: (Map<String, dynamic> json) => TrailExtModel.fromJson(
        json,
        skipNotPubAndInTrash: true,
      ),
    );

    await storageServ.preDownloadTrailUUIDs(res);

    return res ?? [];
  }

  Future<List<TrailExtModel>> fnTrailsLikesTopFetch({
    required String userId,
    // --
    int? limit,
    int? offset,
  }) async {
    final res = await callRPC<TrailExtModel>(
      'tc_fn_trails_likes_top_fetch',
      params: {
        'f_user_id': userId,
        // --
        'f_limit': limit,
        'f_offset': offset,
      },
      fnJson: TrailExtModel.fromJson,
    );

    await storageServ.preDownloadTrailUUIDs(res);

    return res ?? [];
  }

  Future<void> fnTrailsLike({
    required String userId,
    required String trailId,
    required bool like,
  }) async {
    await callRPC(
      'tc_fn_trails_like',
      params: {
        'f_user_id': userId,
        'f_trail_id': trailId,
        'f_like': like,
      },
    );
  }
}
