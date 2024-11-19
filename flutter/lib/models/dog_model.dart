// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:io';

import 'package:trailcatch/getit.dart';
import 'package:trailcatch/utils/core_utils.dart';

class DogModel {
  DogModel({
    required this.dogId,
    required this.userId,
    required this.name,
    required this.gender,
    required this.birthdate,
    required this.age,
    required this.breedId,
    required this.breedCustomName,
    required this.inOurHeartsDateAt,
    // -- --
    required this.json,
  });

  final String dogId;
  final String userId;
  String name;
  int gender;
  DateTime birthdate;
  int age;
  int breedId;
  String breedCustomName;
  DateTime? inOurHeartsDateAt;

  // -- --

  final Map<String, dynamic> json;

  // -- --

  File? get cachePictureFile {
    return userId != '0' ? storageServ.uuidToFile(uuid: dogId) : null;
  }

  factory DogModel.fromJson(Map<String, dynamic> json) {
    final birthdate = DateTime.parse(json['birthdate']);
    final death = DateTime.tryParse(json['in_our_hearts_date_at'] ?? '');

    return DogModel(
      dogId: json['dog_id'],
      userId: json['user_id'],
      name: json['name'],
      gender: json['gender'],
      birthdate: birthdate,
      age: fnAge(birthdate, death: death),
      breedId: json['breed_id'],
      breedCustomName: json['breed_custom_name'],
      inOurHeartsDateAt: death,
      // --
      json: json,
    );
  }

  factory DogModel.empty(int dogCount) {
    return DogModel.fromJson({
      'dog_id': '$dogCount',
      'user_id': '0',
      'name': '',
      'gender': 0,
      'birthdate': '1900-01-01',
      'breed_id': 0,
      'breed_custom_name': '',
      'in_our_hearts_date_at': null,
    });
  }
}
