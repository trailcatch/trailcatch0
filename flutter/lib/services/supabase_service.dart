// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trailcatch/services/crash_service.dart';

import 'package:trailcatch/utils/core_utils.dart';

final SupabaseClient supabase = Supabase.instance.client;

abstract class SupabaseService {
  StorageFileApi supaImages = supabase.storage.from('***');

  static Future<void> init() async {
    await Supabase.initialize(
      url: fnDotEnv('***'),
      anonKey: fnDotEnv('***'),
      authOptions: FlutterAuthClientOptions(
        localStorage: _SecureStorage(),
        autoRefreshToken: true,
      ),
      debug: false,
    );
  }

  Future<dynamic> callRPC<T>(
    String fn, {
    Map<String, dynamic>? params,
    T Function(Map<String, dynamic>)? fnJson,
  }) async {
    try {
      final res = await supabase.rpc(fn, params: params);
      if (fnJson != null && res != null) {
        if (res is List<dynamic>) {
          return res.map((json) => fnJson(json)).toList();
        } else if (res is Map<String, dynamic>) {
          return fnJson(res);
        }
      } else {
        return res;
      }
    } catch (error, stack) {
      CrashService.recordError(
        error,
        stack: stack,
        pgFn: fn,
        pgParams: params,
      );
      return null;
    }
  }
}
