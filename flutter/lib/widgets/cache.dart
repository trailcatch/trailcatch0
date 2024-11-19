// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:trailcatch/models/user_model.dart';
// import 'package:trailcatch/supabase.dart';

class AppCache {
  static const key = 'appCache';

  // static CacheManager instance = CacheManager(
  //   Config(
  //     key,
  //     stalePeriod: const Duration(days: 365),
  //     repo: JsonCacheInfoRepository(databaseName: key),
  //   ),
  // );
}

class AppProfilePicture extends StatefulWidget {
  const AppProfilePicture({
    super.key,
    required this.userId,
  });

  // final UserModel user;
  final String userId;

  @override
  State<AppProfilePicture> createState() => _AppProfilePictureState();
}

class _AppProfilePictureState extends State<AppProfilePicture> {
  late String _cacheKey;
  String _imageUrl =
      'https://gzsolfcznbljhlblfslo.supabase.co/storage/v1/object/sign/tc_bucket_images/5608cb57-e015-4d7a-a2f8-a7723277e552/picture.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJ0Y19idWNrZXRfaW1hZ2VzLzU2MDhjYjU3LWUwMTUtNGQ3YS1hMmY4LWE3NzIzMjc3ZTU1Mi9waWN0dXJlLmpwZyIsImlhdCI6MTcxOTIyNzgzMCwiZXhwIjoxNzE5MjMxNDMwfQ.nRvD_yirKCDAkNgImqqOSDeXG2EzkOVjF7pllWcYobk';

  @override
  void initState() {
    // _cacheKey = widget.user.userId;
    _cacheKey = widget.userId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    // return CachedNetworkImage(
    //   cacheKey: _cacheKey,
    //   imageUrl: _imageUrl,
    //   memCacheHeight: 180,
    //   memCacheWidth: 180,
    //   errorWidget: (context, url, error) {
    //     return const AppProgressIndicator();
    //   },
    //   errorListener: (_) async {
    //     // final imageUrl = await supabase.storage
    //     //     .from('tc_bucket_images')
    //     //     .createSignedUrl('$_cacheKey/picture.jpg', 3600);

    //     // print(imageUrl);

    //     // final ss = Uri.parse(imageUrl).host;

    //     // setState(() {
    //     //   _imageUrl = imageUrl;
    //     // });
    //   },
    // );
  }
}
