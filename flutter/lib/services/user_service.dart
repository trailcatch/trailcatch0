// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/notif_model.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/services/supabase_service.dart';

class UserService extends SupabaseService {
  Future<bool> fnUsersUsernameExists({
    required String username,
  }) async {
    return await callRPC(
      'tc_fn_users_username_exists',
      params: {
        'f_username': username,
      },
    );
  }

  Future<String?> fnUsersCreate({
    required String username,
    required String firstName,
    required String lastName,
    required int gender,
    required DateTime birthdate,
    required String? uiso3,
    required Map<String, dynamic> contacts,
    // --
    required String lang,
    required int msrunit,
    required int fdayofweek,
    required int timeformat,
    required String fcmToken,
  }) async {
    return await callRPC(
      'tc_fn_users_create',
      params: {
        'f_username': username,
        'f_first_name': firstName,
        'f_last_name': lastName,
        'f_gender': gender,
        'f_birthdate': birthdate.toSimpleDate(),
        'f_uiso3': uiso3,
        'f_contacts': contacts,
        // --
        'f_lang': lang,
        'f_msrunit': msrunit,
        'f_fdayofweek': fdayofweek,
        'f_timeformat': timeformat,
        'f_fcm_token': fcmToken,
      },
    );
  }

  Future<UserModel?> fnUsersFetch({
    required String userId,
  }) async {
    final UserModel? user = await callRPC<UserModel>(
      'tc_fn_users_fetch',
      params: {
        'f_user_id': userId,
      },
      fnJson: UserModel.fromJson,
    );

    if (user == null) return null;

    await storageServ.preDownloadUserUUID(user);
    storageServ.preDownloadUserDogsUUID(user);

    return user;
  }

  Future<UserSettingsModel?> fnUsersSettingsFetch() async {
    return await callRPC(
      'tc_fn_users_settings_fetch',
      fnJson: UserSettingsModel.fromJson,
    );
  }

  Future<void> fnUsersUpdate({
    String? username,
    String? firstName,
    String? lastName,
    int? gender,
    DateTime? birthdate,
    String? uiso3,
    Map<String, dynamic>? contacts,
    // --
    String? lang,
    int? msrunit,
    int? fdayofweek,
    int? timeformat,
    int? faceid,
    // --
    bool? notifPushLikes,
    bool? notifPushSubscribers,
    // --
    String? fcmToken,
    bool? appTrackingTransparency,
    DateTime? trialAt,
  }) async {
    username ??= appVM.user.username;
    firstName ??= appVM.user.firstName;
    lastName ??= appVM.user.lastName;
    gender ??= appVM.user.gender;
    birthdate ??= appVM.settings.birthdate;
    uiso3 ??= appVM.user.uiso3;
    contacts ??= appVM.user.contacts;
    lang ??= appVM.settings.lang;
    msrunit ??= appVM.settings.msrunit;
    fdayofweek ??= appVM.settings.fdayofweek;
    timeformat ??= appVM.settings.timeformat;
    faceid ??= appVM.settings.faceid;
    notifPushLikes ??= appVM.settings.notifPushLikes;
    notifPushSubscribers ??= appVM.settings.notifPushSubscribers;
    fcmToken ??= appVM.settings.fcmToken;
    appTrackingTransparency ??= appVM.settings.appTrackingTransparency;
    trialAt ??= appVM.settings.trialAt;

    await callRPC(
      'tc_fn_users_update',
      params: {
        'f_username': username,
        'f_first_name': firstName,
        'f_last_name': lastName,
        'f_gender': gender,
        'f_birthdate': birthdate.toIso8601String(),
        'f_uiso3': uiso3,
        'f_contacts': contacts,
        // --
        'f_lang': lang,
        'f_msrunit': msrunit,
        'f_fdayofweek': fdayofweek,
        'f_timeformat': timeformat,
        'f_faceid': faceid,
        // --
        'f_notif_push_likes': notifPushLikes,
        'f_notif_push_subscribers': notifPushSubscribers,
        // --
        'f_fcm_token': fcmToken,
        'f_app_tracking_transparency': appTrackingTransparency,
        'f_trial_at': trialAt?.toUtc().toIso8601String(),
      },
    );
  }

  Future<bool> fnUsersDelete() async {
    return await callRPC(
      'tc_fn_users_delete',
    );
  }

  Future<String?> fnUsersDogsUpsert({
    required String? dogId,
    // --
    required String name,
    required int gender,
    required DateTime birthdate,
    required int breedId,
    required String breedCustomName,
    required DateTime? inOurHeartsDateAt,
  }) async {
    String? dogId0 = await callRPC(
      'tc_fn_users_dogs_upsert',
      params: {
        'f_dog_id': dogId,
        // --
        'f_name': name,
        'f_gender': gender,
        'f_birthdate': birthdate.toSimpleDate(),
        'f_breed_id': breedId,
        'f_breed_custom_name': breedCustomName,
        'f_in_our_hearts_date_at': inOurHeartsDateAt?.toSimpleDate(),
      },
    );

    return dogId ?? dogId0;
  }

  Future<void> fnUsersDogsDelete({
    required String dogId,
  }) async {
    await callRPC(
      'tc_fn_users_dogs_delete',
      params: {
        'f_dog_id': dogId,
      },
    );
  }

  Future<void> fnUsersRelationship({
    required String userId,
    required int? rlship,
  }) async {
    await callRPC(
      'tc_fn_users_relationship',
      params: {
        'f_user_id': userId,
        'f_rlship': rlship,
      },
    );
  }

  Future<List<NotifExtModel>> fnUsersNotifsFetch({
    required DateTime? createdFrom,
    required int? limit,
  }) async {
    final res = await callRPC<NotifExtModel>(
      'tc_fn_users_notifs_fetch',
      params: {
        'f_created_from': createdFrom?.toUtc().toIso8601String(),
        'f_limit': limit,
      },
      fnJson: NotifExtModel.fromJson,
    );

    if (res != null) {
      for (NotifExtModel notifExt in res) {
        if (notifExt.user2 != null) {
          await storageServ.preDownloadUserUUID(notifExt.user2!);
          storageServ.preDownloadUserDogsUUID(notifExt.user2!);
        }
      }
    }

    return res ?? [];
  }

  Future<void> fnUsersNotifsMarkAllAsRead() async {
    await callRPC(
      'tc_fn_users_notifs_mark_all_as_read',
    );
  }
}
