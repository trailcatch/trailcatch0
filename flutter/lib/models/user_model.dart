// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:trailcatch/constants.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/dog_model.dart';
import 'package:trailcatch/models/statistic_model.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/utils/pref_utils.dart';

abstract class UserGender {
  static const int notsay = 0;
  static const int male = 1;
  static const int female = 2;
  static const int nonBinary = 3;

  static List<int> get all {
    return [
      UserGender.male,
      UserGender.female,
      UserGender.nonBinary,
      UserGender.notsay,
    ];
  }

  static List<String> get allStr {
    return UserGender.all.map((gnd) => UserGender.format(gnd)).toList();
  }

  static String format(int gender, {bool short = false}) {
    if (gender == 0) return short ? '' : 'I prefer not to say';
    if (gender == 1) return short ? 'M' : 'Male';
    if (gender == 2) return short ? 'F' : 'Female';
    if (gender == 3) return short ? 'NB' : 'Non-binary';

    return '';
  }
}

abstract class UserMeasurementUnit {
  static const int km = 1;
  static const int miles = 2;

  static String format(int unit) {
    return unit == 1 ? 'km' : 'mi';
  }

  static String formatPh(int unit) {
    return unit == 1 ? 'km/h' : 'mi/h';
  }

  static String parseKm(int distance, {int fract = 2}) {
    return (distance / 1000).toStringAsFixed(fract);
  }

  static String parseMiles(int distance, {int fract = 2}) {
    return (distance * 0.0006213712).toStringAsFixed(fract);
  }

  // enhancedSpeed = m/s

  // seconds per 100 meters
  static int parseSpeedSecToKmph(int seconds) {
    return (seconds / 100 * 3.6 * 60).toInt();
  }

  static int parseSpeedSecToMiph(int seconds) {
    return (seconds / 100 * 2.23694 * 60).toInt();
  }

  static int parsePaceSecTo1Kmps(int seconds) {
    return (seconds / 100 * 1000).toInt();
  }

  static int parsePaceSecTo1Mips(int seconds) {
    return (seconds / 100 * 1609).toInt();
  }
}

abstract class UserContact {
  static const String instagram = 'instagram';
  static const String facebook = 'facebook';
  static const String twitter = 'x';
  static const String strava = 'strava';
  static const String youtube = 'youtube';
  static const String email = 'email';

  static const String linstagram = 'https://www.instagram.com/';
  static const String lfacebook = 'https://www.facebook.com/';
  static const String ltwitter = 'https://x.com/';
  static const String lstrava = 'https://www.strava.com/athletes/';
  static const String lyoutube = 'https://www.youtube.com/@';
  static const String lemail = 'mailto:';

  static const String lhinstagram = '~ instagram.com/';
  static const String lhfacebook = '~ facebook.com/';
  static const String lhtwitter = '~ x.com/';
  static const String lhstrava = '~ strava.com/athletes/';
  static const String lhyoutube = '~ youtube.com/@';
  static const String lhemail = '~ mailto: ';

  static String formatToStr(Map<String, dynamic> contacts) {
    String cinstagram = contacts[instagram] ?? '';
    String cfacebook = contacts[facebook] ?? '';
    String ctwitter = contacts[twitter] ?? '';
    String cstrava = contacts[strava] ?? '';
    String cyoutube = contacts[youtube] ?? '';
    String cemail = contacts[email] ?? '';

    return [
      cinstagram.isNotEmpty ? instagram.toTitle() : '',
      cfacebook.isNotEmpty ? facebook.toTitle() : '',
      ctwitter.isNotEmpty ? twitter.toTitle() : '',
      cstrava.isNotEmpty ? strava.toTitle() : '',
      cyoutube.isNotEmpty ? youtube.toTitle() : '',
      cemail.isNotEmpty ? email.toTitle() : '',
    ].where((it) => it.isNotEmpty).map((it) => it.toTitle()).join(', ');
  }

  static List<(String, String)> formatToList(
    Map<String, dynamic> contacts,
  ) {
    final List<(String, String)> list = [];

    if (contacts[instagram] != null && contacts[instagram].isNotEmpty) {
      list.add((instagram.toTitle(), '$linstagram${contacts[instagram]}'));
    }

    if (contacts[facebook] != null && contacts[facebook].isNotEmpty) {
      list.add((facebook.toTitle(), '$lfacebook${contacts[facebook]}'));
    }

    if (contacts[twitter] != null && contacts[twitter].isNotEmpty) {
      list.add((twitter.toTitle(), '$ltwitter${contacts[twitter]}'));
    }

    if (contacts[strava] != null && contacts[strava].isNotEmpty) {
      list.add((strava.toTitle(), '$lstrava${contacts[strava]}'));
    }

    if (contacts[youtube] != null && contacts[youtube].isNotEmpty) {
      list.add((youtube.toTitle(), '$lyoutube${contacts[youtube]}'));
    }

    if (contacts[email] != null && contacts[email].isNotEmpty) {
      list.add((email.toTitle(), '$lemail${contacts[email]}'));
    }

    return list;
  }
}

class UserModel {
  UserModel({
    required this.userId,
    // --
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.uiso3,
    required this.contacts,
    // --
    required this.utcp,
    required this.latestTrailId,
    // --
    required this.rlship,
    required this.subscribers,
    required this.subscriptions,
    required this.trails,
    required this.userLikes,
    required this.statistics,
    required this.dogs0,
    // -- --
    required this.trailsTypes,
    // -- --
    required this.statsGit,
    required this.statsTypes,
    required this.statsLatest6Months,
    required this.statsAllYears,
  });

  final String userId;
  // --
  final String username;
  final String firstName;
  final String lastName;
  final int gender;
  final int age;
  final String? uiso3;
  final Map<String, dynamic> contacts;
  // --
  final int utcp;
  final String? latestTrailId;
  // --

  String get fullName => '${firstName.trim()} ${lastName.trim()}';

  // -- --

  int? rlship;
  int subscribers;
  int subscriptions;
  final int trails;
  final int userLikes;
  final List<StatisticModel> statistics;
  final List<DogModel> dogs0;

  // -- --

  File? get cachePictureFile {
    return storageServ.uuidToFile(uuid: userId);
  }

  // -- --

  bool get isMe => userId == appVM.user.userId;
  bool get isDemo {
    if (!appVM.isUserExists) return false;
    return appVM.authProviders?.$1 == 'email';
  }

  List<DogModel> get dogs =>
      dogs0.where((dog0) => dog0.inOurHeartsDateAt == null).toList();
  bool get withDogs => dogs.isNotEmpty;
  String? dogName(String dogId) {
    return dogs.firstWhereOrNull((it) => it.dogId == dogId)?.name;
  }

  final List<(int, bool)> trailsTypes;

  final Map<int, List<StatisticMonthModel>> statsGit;
  final Map<(DateTime, int, bool), StatisticTypeModel> statsTypes;
  final StatisticLatestMonthsModel statsLatest6Months;
  final StatisticLatestMonthsModel statsAllYears;

  // --

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<StatisticModel> statistics0 = ((json['statistics'] ?? []) as List)
        .map((it) => StatisticModel.fromJson(it))
        .toList();

    final List<(int, bool)> trailsTypes0 = statistics0
        .map((stat) => (stat.type, stat.dogsIds.isNotEmpty))
        .toSet()
        .toList();

    final dogsjsn = (json['dogs'] ?? []) as List<dynamic>;
    dogsjsn.sort((a, b) => a['name'].compareTo(b['name']));

    final List<DogModel> dogs0 = [];
    final List<DogModel> dogsm = [];
    for (var dogjsn in dogsjsn) {
      final dog = DogModel.fromJson(dogjsn);
      if (dog.inOurHeartsDateAt == null) {
        dogs0.add(dog);
      } else {
        dogsm.add(dog);
      }
    }

    dogs0.addAll(dogsm);

    return UserModel(
      userId: json['user_id'],
      // --
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      gender: json['gender'],
      age: json['age'],
      uiso3: json['uiso3'],
      contacts: Map<String, dynamic>.from(json['contacts'] ?? {}),
      // --
      utcp: json['utcp'],
      latestTrailId: json['latest_trail_id'],
      // -- --
      rlship: json['rlship'],
      subscribers: json['subscribers'],
      subscriptions: json['subscriptions'],
      trails: json['trails'],
      userLikes: json['user_likes'],
      statistics: statistics0,
      dogs0: dogs0,
      // -- --
      trailsTypes: trailsTypes0,
      // -- --
      statsGit: fnBuildStatsGit(statistics0),
      statsTypes: fnBuildStatsType(statistics0),
      statsLatest6Months: fnBuildStatsLatestMonths(statistics0, 6),
      statsAllYears: fnBuildStatsAllYears(statistics0),
    );
  }
}

class UserSettingsModel {
  UserSettingsModel({
    required this.birthdate,
    // --
    required this.lang,
    required this.msrunit,
    required this.fdayofweek,
    required this.timeformat,
    required this.faceid,
    // --
    required this.notifPushLikes,
    required this.notifPushSubscribers,
    // --
    required this.fcmToken,
    required this.appTrackingTransparency,
    required this.trialAt,
    // --
    required this.etc,
    // --
    required this.createdAt,
    // -- --
    required this.hiddens,
    required this.unreadNotifs,
    required this.daysOfWeek1ch,
  });

  DateTime birthdate;
  String lang;
  int msrunit;
  int fdayofweek;
  int timeformat;
  int faceid;
  // --
  bool notifPushLikes;
  bool notifPushSubscribers;
  // --
  String fcmToken;
  bool appTrackingTransparency;
  DateTime? trialAt;
  // --
  final Map<String, dynamic> etc;
  // --
  final DateTime createdAt;

  // -- --

  final int hiddens;
  int unreadNotifs;
  List<String> daysOfWeek1ch;

  // --

  String? provider;

  // --

  bool get isFree => appVM.plan == null && !isTrialActive;
  bool get isPremium => appVM.plan != null;
  bool get isTrialActive {
    if (isPremium) return false;
    if (trialAt == null) return false;
    return DateTime.now().difference(trialAt!).inDays <= cstTrialDays;
  }

  // --

  Future<bool> isFaceIdRequired() async {
    final isSupported = await fnIsFaceIdSupported();
    if (!isSupported) return false;

    if (faceid == 0) return true;

    final DateTime? dt = await fnPrefGetLastFaceId();
    if (dt == null) {
      return true;
    } else {
      return DateTime.now().difference(dt).inMinutes >= faceid;
    }
  }

  void refreshFirstDays() {
    daysOfWeek1ch = fnDaysOfWeek(fdayofweek, lang);
  }

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    final lang = json['lang'];
    final fdayofweek = json['fdayofweek'];

    return UserSettingsModel(
      birthdate: DateTime.parse(json['birthdate']),
      // --
      lang: lang,
      msrunit: json['msrunit'],
      fdayofweek: fdayofweek,
      timeformat: json['timeformat'],
      faceid: json['faceid'],
      // --
      notifPushLikes: json['notif_push_likes'],
      notifPushSubscribers: json['notif_push_subscribers'],
      // --
      fcmToken: json['fcm_token'] ?? '',
      appTrackingTransparency: json['app_tracking_transparency'],
      trialAt: DateTime.tryParse(json['trial_at'] ?? '')?.toLocal(),
      // --
      etc: Map<String, dynamic>.from(json['etc']),
      // --
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      // -- --
      hiddens: json['hiddens'],
      unreadNotifs: json['unread_notifs'],
      daysOfWeek1ch: fnDaysOfWeek(fdayofweek, lang),
    );
  }

  factory UserSettingsModel.empty() {
    return UserSettingsModel(
      birthdate: DateTime(1900, 1, 1),
      lang: 'en',
      msrunit: 1,
      fdayofweek: 1,
      timeformat: 24,
      faceid: -1,
      notifPushLikes: false,
      notifPushSubscribers: false,
      fcmToken: '',
      appTrackingTransparency: false,
      trialAt: null,
      etc: {},
      createdAt: DateTime(1900, 1, 1),
      hiddens: 0,
      unreadNotifs: 0,
      daysOfWeek1ch: fnDaysOfWeek(1, 'en'),
    );
  }
}
