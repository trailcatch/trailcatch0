// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:convert';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/utils/core_utils.dart';

final EncryptedSharedPreferences _storage = EncryptedSharedPreferences();

Future<void> fnPrefClearAll() async {
  await _storage.clear();
}

//+ last login

Future<void> fnPrefSaveLastLogin(String provider) async {
  await fnTry(() async {
    await _storage.setString(
      '***_LOGIN',
      '$provider,${DateTime.now().toSimpleDate()}',
    );
  });
}

Future<String?> fnPrefGetLastLogin() async {
  return await fnTry(() async {
    return await _storage.getString('***_LOGIN');
  });
}

//+ filters

Future<void> fnPrefSaveTrailFilters(Map<String, dynamic> json) async {
  await fnTry(() async {
    await _storage.setString('***_FILTERS', jsonEncode(json));
  });
}

Future<Map<String, dynamic>> fnPrefGetTrailFilters() async {
  try {
    final res = await _storage.getString('***_FILTERS');
    if (res.isEmpty) return Map<String, dynamic>.from({});

    return jsonDecode(res);
  } catch (_) {}

  return {};
}

Future<void> fnPrefClearTrailFilters() async {
  await fnTry(() async {
    try {
      await _storage.remove('***_FILTERS');
    } catch (_) {
      // todo
    }
  });
}

//+ lang

Future<void> fnPrefSaveLang(String lang) async {
  await fnTry(() async {
    await _storage.setString('***_LANG', lang);
  });
}

Future<String> fnPrefGetLang() async {
  return await fnTry(() async {
    return await _storage.getString('***_LANG');
  });
}

//+ faceid

Future<void> fnPrefSaveLastFaceId() async {
  await fnTry(() async {
    await _storage.setString(
      '***_DATE',
      DateTime.now().toUtc().toIso8601String(),
    );
  });
}

Future<DateTime?> fnPrefGetLastFaceId() async {
  return await fnTry(() async {
    final str = await _storage.getString('***_DATE');
    if (str.isNotEmpty) {
      return DateTime.tryParse(str)?.toLocal();
    }

    return null;
  });
}

//+ notifs

Future<void> fnPrefSaveNotifsShowFullNames(String value) async {
  await fnTry(() async {
    await _storage.setString('***_FULLNAMES', value);
  });
}

Future<String> fnPrefGetNotifsShowFullNames() async {
  return await fnTry(() async {
    return await _storage.getString('***_FULLNAMES');
  });
}

//+ your city

Future<void> fnPrefSaveYourCity(String value) async {
  await fnTry(() async {
    await _storage.setString('***_CITY', value);
  });
}

Future<String> fnPrefGetYourCity() async {
  return await fnTry(() async {
    return await _storage.getString('***_CITY');
  });
}

Future<void> fnPrefClearYourCity() async {
  await fnTry(() async {
    try {
      await _storage.remove('***_CITY');
    } catch (_) {}
  });
}

//+ apple creds

Future<void> fnPrefSaveAppleCreds(Map<String, dynamic> value) async {
  await fnTry(() async {
    await _storage.setString('***_CREDS', jsonEncode(value));
  });
}

Future<Map<String, dynamic>> fnPrefGetAppleCreds() async {
  return await fnTry(() async {
    final str = await _storage.getString('***_CREDS');
    if (str.isNotEmpty) {
      return jsonDecode(str);
    }

    return Map<String, dynamic>.from({});
  });
}
