// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:get_it/get_it.dart';

import 'package:trailcatch/services/storage_service.dart';
import 'package:trailcatch/viewmodels/app_viewmodel.dart';
import 'package:trailcatch/viewmodels/device_viewmodel.dart';
import 'package:trailcatch/viewmodels/notif_viewmodel.dart';
import 'package:trailcatch/viewmodels/status_viewmodel.dart';
import 'package:trailcatch/viewmodels/trail_viewmodel.dart';

import 'package:trailcatch/services/auth_service.dart';
import 'package:trailcatch/services/trail_service.dart';
import 'package:trailcatch/services/user_service.dart';
import 'package:trailcatch/services/crash_service.dart';
import 'package:trailcatch/services/firebase_service.dart';

import 'package:trailcatch/services/device/device_garmin_service.dart';
import 'package:trailcatch/services/device/device_polar_service.dart';
import 'package:trailcatch/services/device/device_suunto_service.dart';

final GetIt _getIt = GetIt.instance;

Future<void> setupGetIt() async {
  //+ vms
  _getIt.registerLazySingleton<AppViewModel>(() => AppViewModel());
  _getIt.registerLazySingleton<StatusViewModel>(() => StatusViewModel());
  _getIt.registerLazySingleton<TrailViewModel>(() => TrailViewModel());
  _getIt.registerLazySingleton<DeviceViewModel>(() => DeviceViewModel());
  _getIt.registerLazySingleton<NotifViewModel>(() => NotifViewModel());

  //+ services
  _getIt.registerLazySingleton<AuthService>(() => AuthService());
  _getIt.registerLazySingleton<UserService>(() => UserService());
  _getIt.registerLazySingleton<TrailService>(() => TrailService());
  _getIt.registerLazySingleton<CrashService>(() => CrashService());
  _getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
  _getIt.registerLazySingleton<StorageService>(() => StorageService());

  //+ devices
  _getIt.registerLazySingleton<DeviceGarminService>(
    () => DeviceGarminService(),
  );
  _getIt.registerLazySingleton<DeviceSuuntoService>(
    () => DeviceSuuntoService(),
  );
  _getIt.registerLazySingleton<DevicePolarService>(
    () => DevicePolarService(),
  );
}

final AppViewModel appVM = _getIt<AppViewModel>();
final StatusViewModel stVM = _getIt<StatusViewModel>();
final TrailViewModel trailVM = _getIt<TrailViewModel>();
final DeviceViewModel deviceVM = _getIt<DeviceViewModel>();
final NotifViewModel notifVM = _getIt<NotifViewModel>();

final AuthService authServ = _getIt<AuthService>();
final UserService userServ = _getIt<UserService>();
final TrailService trailServ = _getIt<TrailService>();
final CrashService crashServ = _getIt<CrashService>();
final FirebaseService fbServ = _getIt<FirebaseService>();
final StorageService storageServ = _getIt<StorageService>();

final DeviceGarminService devGarminServ = _getIt<DeviceGarminService>();
final DeviceSuuntoService devSuuntoServ = _getIt<DeviceSuuntoService>();
final DevicePolarService devPolarServ = _getIt<DevicePolarService>();
