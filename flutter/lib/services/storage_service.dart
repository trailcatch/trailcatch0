// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:io';

import 'package:fc_native_image_resize/fc_native_image_resize.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/services/supabase_service.dart';

class StorageService extends SupabaseService {
  late final String _dirPath;

  Future<void> init() async {
    _dirPath = (await getTemporaryDirectory()).path;
  }

  //+ pictures

  String uuidJpg(String userId, String uuid) => '$userId/$uuid.jpg';

  Future<void> uploadPictureUUID({
    required String userId,
    required String uuid,
    required String filePath,
  }) async {
    final File file = File('$_dirPath/***_$uuid.jpg');
    await FcNativeImageResize().resizeFile(
      srcFile: filePath,
      destFile: file.path,
      width: 1024,
      height: 1024,
      keepAspectRatio: true,
      format: 'jpeg',
      quality: 90,
    );

    await supaImages.upload(
      uuidJpg(userId, uuid),
      file,
      retryAttempts: 2,
      fileOptions: const FileOptions(upsert: true),
    );
  }

  Uint8List? _emptyBytes;
  Future<void> downloadPictureUUID({
    required String userId,
    required String uuid,
  }) async {
    final File? file = uuidToFile(uuid: uuid, anySize: true);
    if (file != null) return;

    try {
      final Uint8List bytes = await supaImages.download(uuidJpg(userId, uuid));
      final File file = File('$_dirPath/***_$uuid.jpg');
      await file.writeAsBytes(bytes);
    } catch (error) {
      if (error is StorageException && error.error == 'not_found') {
        if (_emptyBytes == null) {
          final bytes = await rootBundle.load('assets/***/empty.png');
          _emptyBytes = bytes.buffer.asUint8List();
        }

        final File file = File('$_dirPath/***_$uuid.jpg');
        file.writeAsBytes(_emptyBytes!);
      }
    }
  }

  Future<void> deletePictureUUID({
    required String userId,
    required String uuid,
  }) async {
    await supaImages.remove([uuidJpg(userId, uuid)]);
  }

  void deleteLocalPictureUUID({
    required String uuid,
  }) {
    final File? file = uuidToFile(uuid: uuid, anySize: true);
    if (file != null) {
      file.deleteSync();
    }
  }

  File? uuidToFile({
    required String uuid,
    bool anySize = false,
  }) {
    final File file = File('$_dirPath/***_$uuid.jpg');
    if (file.existsSync()) {
      if (anySize || file.statSync().size > 150) {
        return file;
      }
    }
    return null;
  }

  Future<void> preDownloadUserUUID(UserModel user) async {
    await storageServ.downloadPictureUUID(
      userId: user.userId,
      uuid: user.userId,
    );
  }

  void preDownloadUserDogsUUID(UserModel user) {
    for (var dog in user.dogs0) {
      storageServ.downloadPictureUUID(
        userId: user.userId,
        uuid: dog.dogId,
      );
    }
  }

  Future<void> preDownloadTrailUUIDs(List<TrailExtModel>? trailExts) async {
    if (trailExts == null) return;

    for (var trailExt in trailExts) {
      await preDownloadUserUUID(trailExt.user);

      for (String uuid in trailExt.likesLatest4) {
        await storageServ.downloadPictureUUID(
          userId: uuid,
          uuid: uuid,
        );
      }
    }
  }
}
