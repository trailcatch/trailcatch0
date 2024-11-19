// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:app_settings/app_settings.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nsfw_detector_flutter/nsfw_detector_flutter.dart';
import 'package:safe_text/safe_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:trailcatch/context.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/dog_model.dart';
import 'package:trailcatch/models/statistic_model.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/services/crash_service.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';

abstract class AppErrorCode {
  // 4xx
  static const String offline = '***';
  static const String error = '***';

  static const String signInWithApple = '***';
  static const String signInWithGoogle = '***';
  static const String signInWithOAuth = '***';

  static const String accountNotFound = '***';
  static const String nudePhoto = '***';

  static const String faceId = '***';
  static const String trailNotFound = '***';

  // 5xx
  static const String supaPg = '***';
  static const String supaAuth = '***';
  static const String supaStorage = '***';

  static const String fitParse = '***';
  static const String qonversion = '***';
}

class AppError {
  AppError({
    required this.message,
    required this.code,
    this.error,
    this.stack,
  });

  String message;
  final String code;
  final dynamic error;
  final dynamic stack;

  @override
  String toString() {
    return 'ERROR [$code]: $message';
  }

  String toStringF() {
    return error.toString();
  }
}

class LatLng {
  LatLng(this.lat, this.lng);

  final double lat;
  final double lng;

  @override
  String toString() => '$lat,$lng';

  List<double> toPGArray() => [lng, lat];

  static String? toPGMultiPointSRID(List<LatLng>? geopoints) {
    if (geopoints == null) return null;

    String line = geopoints.map((geopoint) {
      return '(${geopoint.lng} ${geopoint.lat})';
    }).join(',');

    return 'SRID=4326;MULTIPOINT($line)';
  }

  static List<LatLng>? fromPGMultiPointSRID(String? pgText) {
    if (pgText == null || pgText.isEmpty) return null;

    final List<LatLng> geopoints = [];

    pgText = pgText.replaceAll('SRID=4326;', '');
    pgText = pgText.replaceAll('MULTIPOINT(', '');
    pgText = pgText.substring(0, pgText.length - 1);
    pgText = pgText.trim();

    final pgTextArr = pgText.split(',');
    for (var pgTextIt in pgTextArr) {
      pgTextIt = pgTextIt.replaceAll('(', '');
      pgTextIt = pgTextIt.replaceAll(')', '');
      final pgTextItArr = pgTextIt.trim().split(' ');
      final lat = double.tryParse(pgTextItArr.last);
      final lng = double.tryParse(pgTextItArr.first);

      if (lat != null && lng != null) {
        geopoints.add(LatLng(lat, lng));
      }
    }

    return geopoints;
  }

  static LatLng fromSemicircles(int posLat, int posLng) {
    return LatLng(
      (posLat / (1 << 31)) * 180,
      (posLng / (1 << 31)) * 180,
    );
  }
}

class AppDebouncer {
  final Duration? delay;
  Timer? _timer;

  AppDebouncer({this.delay});

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay!, action);
  }

  void cancel() => _timer?.cancel();
}

class SyncDate {
  const SyncDate({
    this.from,
    this.to,
    this.offset,
    this.limit,
  });

  final DateTime? from;
  final DateTime? to;
  final int? offset;
  final int? limit;
}

//+ utils

Future<dynamic> fnTry(
  Future<dynamic> Function() fn, {
  Duration? delay,
}) async {
  try {
    if (delay != null) {
      dynamic ffnRes;
      Future<dynamic> ffn() async {
        ffnRes = await fn();
      }

      await Future.wait([
        Future.delayed(delay),
        ffn(),
      ]);

      return ffnRes;
    } else {
      return await fn();
    }
  } catch (error, stack) {
    CrashService.recordError(error, stack: stack);
    return null;
  }
}

Future<bool> fnIsOnline() async {
  try {
    final response = await Dio().get('https://www.google.com');
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (_) {
    return false;
  }
}

// --

String fnEncodeAES(String value) {
  final key = encrypt.Key.fromUtf8(fnDotEnv('***'));
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final encrypted = encrypter.encrypt(value, iv: iv);

  final ivBase64 = iv.base64;
  final encryptedBase64 = encrypted.base64;

  return '$ivBase64:$encryptedBase64';
}

String fnDecodeAES(String value) {
  final key = encrypt.Key.fromUtf8(fnDotEnv('***'));
  final parts = value.split(':');
  final iv = encrypt.IV.fromBase64(parts[0]);
  final encrypted = encrypt.Encrypted.fromBase64(parts[1]);

  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final decrypted = encrypter.decrypt(encrypted, iv: iv);

  return decrypted;
}

String fnDotEnv(String key) {
  return dotenv.maybeGet(key, fallback: '')!;
}

//+ ages

int fnAge(DateTime date, {DateTime? death}) {
  return (death ?? DateTime.now()).difference(date).inDays ~/ 365;
}

String fnAgeGroupFromBirthdayOrAge({
  DateTime? birthday,
  int? age,
}) {
  age = age ?? 0;
  if (birthday != null) {
    age = fnAge(birthday);
  }

  if (age == 0) return '0';

  List<List<int>> groups = [
    [16, 19],
    [20, 24],
    [25, 29],
    [30, 34],
    [35, 39],
    [40, 44],
    [45, 49],
    [50, 54],
    [55, 59],
    [60, 64],
    [65, 69],
    [70, 74],
    [75, 79],
    [80, 84],
    [85, 90],
    [90, 120]
  ];

  for (var group in groups) {
    if (age >= group.first && age <= group.last) {
      if (group.first == 90) return '90+';
      return '${group.first} - ${group.last}';
    }
  }

  return '0';
}

List<(String, List<int>)> fnAgeGroups({bool allGroups = false}) {
  List<List<int>> groups = [
    [16, 19],
    [20, 24],
    [25, 29],
    [30, 34],
    [35, 39],
    [40, 44],
    [45, 49],
    [50, 54],
    [55, 59],
    [60, 64],
    [65, 69],
    [70, 74],
    [75, 79],
    [80, 120],
  ];

  return [
    for (var group in groups.reversed)
      if (group.first == 80)
        ('80+', group)
      else
        ('${group.first} - ${group.last}', group),
    if (allGroups) ('All groups', []),
  ];
}

List<(String, List<int>)> fnAgeGroupsS() {
  List<List<int>> groups = [
    [16, 19],
    [20, 29],
    [30, 39],
    [40, 49],
    [50, 59],
    [60, 69],
    [70, 79],
    [80, 120],
  ];

  return [
    for (var group in groups.reversed)
      if (group.first == 80)
        ('80+', group)
      else
        ('${group.first} - ${group.last}', group),
  ];
}

String fnAgeGroup({
  required int gender,
  required int age,
}) {
  String str = UserGender.format(gender, short: true).trim();
  if (str.isNotEmpty) str += ' ';
  str += fnAgeGroupFromBirthdayOrAge(age: age).trim();
  if (str == '0') str = '';
  str = str.trim();
  if (str == 'F 0') str = '';
  if (str == 'M 0') str = '';

  if (str.isEmpty) str = '';

  return str;
}

String fnDogAge(DogModel dog) {
  String dogAge = UserGender.format(dog.gender, short: true).trim();
  if (dogAge.isNotEmpty) dogAge += ' ';
  dogAge += '${dog.age}'.trim();
  if (dog.age == 0) dogAge += '+';

  return dogAge;
}

//-

(String, String, String) fnFullNameFromAuth(User user) {
  String username = '';
  String firstName = '';
  String lastName = '';

  if (user.appMetadata.isNotEmpty) {
    if (user.appMetadata['provider'] == 'google' ||
        user.appMetadata['provider'] == 'github' ||
        user.appMetadata['provider'] == 'twitter' ||
        user.appMetadata['provider'] == 'facebook' ||
        user.appMetadata['provider'] == 'discord') {
      String fullName = user.userMetadata?['full_name'] ?? '';
      if (fullName.isNotEmpty) {
        if (fullName.contains(' ')) {
          firstName = fullName.split(' ').first;
          lastName = fullName.split(' ').last;
        } else {
          firstName = fullName;
        }

        username = [firstName, lastName]
            .where((fl) => fl.isNotEmpty)
            .join('.')
            .toLowerCase();
      } else {
        if (user.email != null && user.email!.contains('@')) {
          username = user.email!.split('@').first;
        }
      }
    } else if (user.appMetadata['provider'] == 'apple') {
      firstName = appVM.appleGivenName ?? '';
      lastName = appVM.appleFamilyName ?? '';
      username = [firstName, lastName]
          .where((fl) => fl.isNotEmpty)
          .join('.')
          .toLowerCase();
    }
  }

  return (username, firstName, lastName);
}

String fnCountryIso3ByName(String name) {
  for (var country in appVM.countries) {
    if (country['name'] == name) return country['iso3']!;
  }

  return '';
}

String fnCountryNameByIso3(String? iso3) {
  if (iso3 == null) return '';

  for (var country in appVM.countries) {
    if (country['iso3'] == iso3) return country['name']!;
  }

  return '';
}

// Username must be at least 5 and no more than 30 characters long,
// and can contain only letters, numbers and underscores.
bool fnValidateUsername(String text) {
  RegExp exp = RegExp(r'^[A-Za-zА-Яа-я][A-Za-z0-9А-Яа-я0-9_.]{5,29}$');
  return exp.hasMatch(text);
}

// FullName must be at least 3 and no more than 40 characters long,
// and can contain only letters, numbers and spaces.
bool fnValidateFullName(String text) {
  RegExp exp = RegExp(r'^[A-Za-zА-Яа-я][A-Za-z0-9А-Яа-я0-9\ ]{1,39}$');
  return exp.hasMatch(text);
}

String fnFilterText(String text) {
  List<String> arr = text.split('_');
  List<String> farr = [];

  for (var it in arr) {
    farr.add(SafeText.filterText(
      text: it,
      useDefaultWords: true,
      fullMode: true,
      obscureSymbol: '*',
    ));
  }

  return farr.join('_');
}

String fnDogBreedNameById(int breedId) {
  for (var wikiDog in appVM.wikiDogs) {
    if (wikiDog['id'] == breedId) return wikiDog['name'];
  }

  return '';
}

String fnDogBreedLinkById(int breedId) {
  for (var wikiDog in appVM.wikiDogs) {
    if (wikiDog['id'] == breedId) {
      return 'https://en.wikipedia.org/wiki/${wikiDog['link']}';
    }
  }

  return '';
}

int fnKmOrMiles(String? iso3) {
  if (iso3?.toLowerCase() == 'usa' || iso3?.toLowerCase() == 'gbr') {
    return UserMeasurementUnit.miles;
  }

  return UserMeasurementUnit.km;
}

Future<void> fnPreCacheWikiDogImage5th() async {
  if (appVM.wikiDogsData.isNotEmpty) {
    await fnTry(() async {
      for (var wd in appVM.wikiDogsData.take(5)) {
        if ((wd['picture'] as String).isNotEmpty) {
          precacheImage(NetworkImage(wd['picture']), appContext);
        }
      }
    });
  }
}

String fnNumCompact(int num) {
  if (num <= 9999) return '$num';
  return NumberFormat.compact().format(num).toLowerCase();
}

Future<XFile?> fnImagePicker({
  required bool camera,
}) async {
  final file = await ImagePicker().pickImage(
    source: camera ? ImageSource.camera : ImageSource.gallery,
  );

  if ((await fnIsImageNude(file))) {
    throw AppError(
      message: 'Photo must not contains Nude...',
      code: AppErrorCode.nudePhoto,
    );
  }

  return file;
}

Future<bool> fnIsImageNude(XFile? image) async {
  if (image == null) return false;

  NsfwDetector detector = await NsfwDetector.load();
  NsfwResult? result = await detector.detectNSFWFromFile(File(image.path));

  return result?.isNsfw ?? false;
}

Future<void> fnShowToast(
  String text, {
  Color? textColor,
  BuildContext? context,
}) async {
  Future.delayed(250.mlsec).then((_) {
    if (!appContext.mounted) return;

    ScaffoldMessenger.of(context ?? appContext).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: AppTheme.clBlack,
        duration: const Duration(milliseconds: 1500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        content: Text(
          text,
          style: TextStyle(
            color: textColor ?? AppTheme.clText08,
            fontWeight: FontWeight.bold,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.appLR,
          vertical: 8,
        ),
        margin: const EdgeInsets.only(
          bottom: 10,
          left: AppTheme.appLR,
          right: AppTheme.appLR,
        ),
      ),
    );
  });
}

//+ statistics

void fillStatYearWithEmpty(
  int year,
  Map<int, List<StatisticMonthModel>> value,
) {
  value.putIfAbsent(year, () => []);

  for (var month in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]) {
    value[year]!.add(StatisticMonthModel.empty(DateTime(year, month, 1)));
  }
}

Map<int, List<StatisticMonthModel>> fnBuildStatsGit(List<StatisticModel> data) {
  final git0 = data.groupFoldBy<DateTime, StatisticMonthModel>((it) {
    return DateTime(it.dateAt.year, it.dateAt.month, 1);
  }, (acc, it) {
    return acc = StatisticMonthModel(
      count: (acc?.count ?? 0) + it.count,
      distance: (acc?.distance ?? 0) + it.distance,
      elevation: (acc?.elevation ?? 0) + it.elevation,
      time: (acc?.time ?? 0) + it.time,
      avgPaces: (acc?.avgPaces ?? [])..add(it.avgPace),
      avgSpeeds: (acc?.avgSpeeds ?? [])..add(it.avgSpeed),
      days: ((acc?.days ?? []) + [it.dateAt.day]).toSet().toList()..sort(),
      dateAt: DateTime(it.dateAt.year, it.dateAt.month, 1),
    );
  });

  final int nYear = DateTime.now().year;
  final int lowYear = git0.keys.map((it) => it.year).toSet().minOrNull ?? 2020;
  List<int> years = git0.keys.map((it) => it.year).toSet().toList();
  for (var y in List.generate(nYear - lowYear, (i) => lowYear + i)) {
    if (!years.contains(y)) {
      years.add(y);
    }
  }
  years.sort();

  final Map<int, List<StatisticMonthModel>> git1 = {};

  final nyear = DateTime.now().year;

  if (git0.isEmpty) {
    fillStatYearWithEmpty(nyear, git1);

    return git1;
  }

  for (var year in years) {
    if (!git1.containsKey(year)) {
      git1.putIfAbsent(year, () => []);
    }

    for (var month in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]) {
      final key = git0.keys.firstWhereOrNull(
        (el) => el.year == year && el.month == month,
      );

      if (key != null) {
        git1[year]!.add(git0[key]!);
      } else {
        git1[year]!.add(StatisticMonthModel.empty(DateTime(year, month, 1)));
      }
    }
  }

  if (!years.contains(nyear)) {
    fillStatYearWithEmpty(nyear, git1);
  }

  return git1;
}

StatisticLatestMonthsModel fnBuildStatsLatestMonths(
  List<StatisticModel> data,
  int lastMonths,
) {
  final DateTime now = DateTime.now();
  return data.fold(StatisticLatestMonthsModel.empty(), (acc, it) {
    if (now.difference(it.dateAt).inDays > 30 * lastMonths) return acc;

    acc.count += it.count;
    acc.distance += it.distance;
    acc.elevation += it.elevation;
    acc.time += it.time;

    return acc;
  });
}

StatisticLatestMonthsModel fnBuildStatsAllYears(
  List<StatisticModel> data,
) {
  return data.fold(StatisticLatestMonthsModel.empty(), (acc, it) {
    acc.count += it.count;
    acc.distance += it.distance;
    acc.elevation += it.elevation;
    acc.time += it.time;

    return acc;
  });
}

Map<(DateTime, int, bool), StatisticTypeModel> fnBuildStatsType(
  List<StatisticModel> data,
) {
  return data.groupFoldBy<(DateTime, int, bool), StatisticTypeModel>((it) {
    return (
      DateTime(it.dateAt.year, it.dateAt.month, 1),
      it.type,
      it.dogsIds.isNotEmpty
    );
  }, (acc, it) {
    return acc = StatisticTypeModel(
      type: it.type,
      count: (acc?.count ?? 0) + it.count,
      distance: (acc?.distance ?? 0) + it.distance,
      elevation: (acc?.elevation ?? 0) + it.elevation,
      time: (acc?.time ?? 0) + it.time,
      avgPaces: (acc?.avgPaces ?? [])..add(it.avgPace),
      avgSpeeds: (acc?.avgSpeeds ?? [])..add(it.avgSpeed),
      dogsIds: (acc?.dogsIds ?? []) + it.dogsIds,
      dateAt: DateTime(it.dateAt.year, it.dateAt.month, 1),
    );
  });
}

//-

int fnFirstDayOffset(int year, int month, int firstDayOfWeek) {
  final int weekdayFromMonday = DateTime(year, month).weekday - 1;
  firstDayOfWeek = (firstDayOfWeek - 1) % 7;
  return (weekdayFromMonday - firstDayOfWeek) % 7;
}

List<String> fnDaysOfWeek(int firstDayOfWeek, String lang) {
  final mon = DateTime(2024, 08, 19);
  final tue = DateTime(2024, 08, 20);
  final web = DateTime(2024, 08, 21);
  final thu = DateTime(2024, 08, 22);
  final fri = DateTime(2024, 08, 23);
  final sat = DateTime(2024, 08, 24);
  final sun = DateTime(2024, 08, 25);

  final frm = DateFormat('EEEE', lang);
  final mon1ch = frm.format(mon).substring(0, 1).toUpperCase();
  final tue1ch = frm.format(tue).substring(0, 1).toUpperCase();
  final web1ch = frm.format(web).substring(0, 1).toUpperCase();
  final thu1ch = frm.format(thu).substring(0, 1).toUpperCase();
  final fri1ch = frm.format(fri).substring(0, 1).toUpperCase();
  final sat1ch = frm.format(sat).substring(0, 1).toUpperCase();
  final sun1ch = frm.format(sun).substring(0, 1).toUpperCase();

  final wDays0 = [sun1ch, mon1ch, tue1ch, web1ch, thu1ch, fri1ch, sat1ch];
  final wDays1 = [mon1ch, tue1ch, web1ch, thu1ch, fri1ch, sat1ch, sun1ch];

  return firstDayOfWeek == 0 ? wDays0 : wDays1;
}

String fnDistance(int distance, {int fract = 2, bool compact = false}) {
  String distStr = '0';

  if (appVM.isUserExists) {
    if (appVM.settings.msrunit == 1) {
      distStr = UserMeasurementUnit.parseKm(distance, fract: fract);
    } else if (appVM.settings.msrunit == 2) {
      distStr = UserMeasurementUnit.parseMiles(distance, fract: fract);
    }
  } else {
    distStr = UserMeasurementUnit.parseKm(distance, fract: fract);
  }

  if (compact) {
    double distInt = double.tryParse(distStr) ?? 0.0;
    distStr = fnNumCompact(distInt.toInt());
  }

  return distStr;
}

String fnDistUnit() {
  int msrunit = 1;
  if (appVM.isUserExists) {
    msrunit = appVM.settings.msrunit;
  }

  return UserMeasurementUnit.format(msrunit);
}

String fnTime(
  int seconds, {
  bool short = false,
  bool zero1th = true,
}) {
  int minutes = (seconds % 3600) ~/ 60;
  int remainingSeconds = seconds % 60;

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  String str = '';
  if (!short) {
    int hours = seconds ~/ 3600;
    str += '${twoDigits(hours)}:';
  }

  str += '${twoDigits(minutes)}:${twoDigits(remainingSeconds)}';

  if (!zero1th && str.startsWith('0')) {
    str = str.substring(1);
  }

  return str;
}

String fnTimeExt(
  int seconds, {
  bool short = false,
  bool zero1th = true,
}) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int remainingSeconds = seconds % 60;

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  String str = '';
  if (hours != 0) {
    str += '${twoDigits(hours)}:';
    if (str.startsWith('0')) {
      str = str.substring(1);
    }
  }

  str += twoDigits(minutes);
  if (!short || (short && hours <= 99)) {
    str += '\'${twoDigits(remainingSeconds)}';
  }

  if (!zero1th && str.startsWith('0')) {
    str = str.substring(1);
  }

  if (str == '0') {
    str = '0\'00';
  }

  return str;
}

String fnDateFormat(String pattern, DateTime date) {
  return DateFormat(pattern, appVM.lang).format(date);
}

String fnTimeFormat(DateTime date) {
  if (appVM.settings.timeformat == 24) {
    return DateFormat('HH:mm').format(date);
  } else {
    return DateFormat('hh:mm aaa').format(date);
  }
}

int fnParseSpeedSec(int seconds, int msrunit) {
  if (msrunit == UserMeasurementUnit.km) {
    return UserMeasurementUnit.parseSpeedSecToKmph(seconds);
  } else {
    return UserMeasurementUnit.parseSpeedSecToMiph(seconds);
  }
}

int fnParsePaceSec(int seconds, int msrunit) {
  if (msrunit == UserMeasurementUnit.km) {
    return UserMeasurementUnit.parsePaceSecTo1Kmps(seconds);
  } else {
    return UserMeasurementUnit.parsePaceSecTo1Mips(seconds);
  }
}

// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
int fnWeekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
  if (woy < 1) {
    woy = _fnNumOfWeeks(date.year - 1);
  } else if (woy > _fnNumOfWeeks(date.year)) {
    woy = 1;
  }
  return woy;
}

// Calculates number of weeks for a given year as per https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year
int _fnNumOfWeeks(int year) {
  DateTime dec28 = DateTime(year, 12, 28);
  int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
  return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
}

DateTime addMonth(DateTime date) {
  var year = date.year + ((date.month + 1) ~/ 12);
  var month = (date.month + 1) % 12;
  if (month == 0) month = 12;
  var day = date.day;

  // Adjust day if the result is an invalid date, e.g., adding a month to January 31st
  if (day > 28) {
    day = min(day, DateTime(year, month + 1, 0).day);
  }

  return DateTime(year, month, day, date.hour, date.minute, date.second,
      date.millisecond, date.microsecond);
}

// lang

String? fnDeviceLang() {
  if (Platform.localeName.contains('_')) {
    final String deviceLang = Platform.localeName.split('_').first;
    for (var locale in AppLocalizations.supportedLocales) {
      if (deviceLang == locale.languageCode) {
        return deviceLang;
      }
    }
  }

  return null;
}

// face id

Future<void> fnAppSettings() async {
  try {
    await AppSettings.openAppSettings();
  } catch (_) {}
}

Future<bool> fnIsFaceIdSupported() async {
  try {
    return await LocalAuthentication().isDeviceSupported();
  } on PlatformException catch (_) {}

  return false;
}

Future<bool> fnAskFaceId() async {
  try {
    return await LocalAuthentication().authenticate(
      localizedReason:
          'TrailCatch uses Face ID and Passcode to safeguard your data.',
    );
  } on PlatformException catch (error) {
    if (error.details == 'com.apple.LocalAuthentication' &&
        error.message == 'Authentication canceled.') {
      return false;
    }
  }

  return false;
}

//+ colors

ColorFilter cstColorFilterGreyscale = const ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0
]);

//+ vibr

void fnHaptic() {
  HapticFeedback.mediumImpact();
}

//+ sort trail

void fnSortTrailsDateDesc(List<TrailExtModel> trailsExt) {
  trailsExt.sort((a, b) => b.trail.datetimeAt.compareTo(a.trail.datetimeAt));
}

//+ num index center

int fnMiddleIndex(List<int> nums) {
  if (nums.isEmpty) return -1;
  return nums.length ~/ 2;
}

//+ device model names
String fnParseDeviceModelIncr(String deviceModel) {
  if (deviceModel == 'Instinct2') {
    return 'Instinct 2';
  }

  return deviceModel;
}

//+ root widget error
Widget fnRootWidgetError(
  BuildContext context, {
  required String title,
}) {
  return AppSimpleScaffold(
    title: title,
    hideBack: true,
    child: Column(
      children: [
        10.h,
        Text(
          'Error.',
          style: TextStyle(fontSize: 17),
        ),
        10.h,
        AppSimpleButton(
          width: context.width * AppTheme.appBtnWidth,
          onTap: () {
            AppRoute.goTo('/splash');
          },
          text: 'Reload App',
        ),
      ],
    ),
  );
}

//+ provider

String fnProviderToString(String provider) {
  provider = provider.toLowerCase();
  String providerStr = provider.toTitle();

  if (provider == 'github') {
    providerStr = 'GitHub';
  } else if (provider == 'twitter') {
    providerStr = 'X';
  }

  return providerStr;
}
