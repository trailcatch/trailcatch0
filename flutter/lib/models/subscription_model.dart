// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

class SubscriptionModel {
  SubscriptionModel({
    required this.json,
    // --
    required this.productIdentifier,
    required this.periodType,
    required this.expirationDate,
    required this.latestPurchaseDate,
    required this.willRenew,
    required this.originalAppUserId,
    required this.originalApplicationVersion,
    required this.originalPurchaseDate,
  });

  final Map<String, dynamic> json;
  // --
  final String productIdentifier;
  final String periodType;
  final DateTime? expirationDate;
  final DateTime? latestPurchaseDate;
  final bool willRenew;
  final String originalAppUserId;
  final String? originalApplicationVersion;
  final DateTime? originalPurchaseDate;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      json: json,
      productIdentifier: json['productIdentifier'] ?? '',
      periodType: json['periodType'] ?? '',
      expirationDate:
          DateTime.tryParse(json['expirationDate'] ?? '')?.toLocal(),
      latestPurchaseDate:
          DateTime.tryParse(json['latestPurchaseDate'] ?? '')?.toLocal(),
      willRenew: json['willRenew'] ?? false,
      originalAppUserId: json['originalAppUserId'] ?? '',
      originalApplicationVersion: json['originalApplicationVersion'] ?? '',
      originalPurchaseDate:
          DateTime.tryParse(json['originalPurchaseDate'] ?? '')?.toLocal(),
    );
  }
}
