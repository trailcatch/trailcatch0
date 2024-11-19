// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/logger.dart';
import 'package:trailcatch/services/crash_service.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/services/supabase_service.dart';
import 'package:trailcatch/utils/pref_utils.dart';

class AuthService extends SupabaseService {
  Stream<AuthState> onAuthStateChange() => supabase.auth.onAuthStateChange;

  //+ auth apple

  Future<void> signInWithApple() async {
    final rawNonce = supabase.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    if (credential.givenName != null) {
      await fnPrefSaveAppleCreds({
        'givenName': credential.givenName,
        'familyName': credential.familyName,
        'email': credential.email,
      });
    }

    await appVM.reAppleCreds();

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw AppError(
        message: 'Could not find ID Token from generated credential.',
        code: AppErrorCode.signInWithApple,
        error: null,
      );
    }

    try {
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
    } catch (error, stack) {
      CrashService.recordError(
        AppError(
          message: 'Apple Auth Error',
          code: AppErrorCode.signInWithApple,
          error: error,
          stack: stack,
        ),
        stack: stack,
      );
    }
  }

  //+ auth google

  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: fnDotEnv('***'),
      serverClientId: fnDotEnv('***'),
    );

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw AppError(
        message: 'No Access Token found.',
        code: AppErrorCode.signInWithGoogle,
        error: null,
      );
    }

    if (idToken == null) {
      throw AppError(
        message: 'No ID Token found.',
        code: AppErrorCode.signInWithGoogle,
        error: null,
      );
    }

    try {
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (error, stack) {
      CrashService.recordError(
        AppError(
          message: 'Google Auth Error',
          code: AppErrorCode.signInWithGoogle,
          error: error,
          stack: stack,
        ),
        stack: stack,
      );
    }
  }

  //+ auth facebook

  Future<void> signInWithFacebook() async {
    await signInWithOAuth(OAuthProvider.facebook);
  }

  //+ auth twitter

  Future<void> signInWithTwitter() async {
    await signInWithOAuth(OAuthProvider.twitter);
  }

  //+ auth github

  Future<void> signInWithGitHub() async {
    await signInWithOAuth(OAuthProvider.github);
  }

  //+ auth github

  Future<void> signInWithDiscord() async {
    await signInWithOAuth(OAuthProvider.discord);
  }

  //+ OAuth

  Future<void> signInWithOAuth(OAuthProvider provider) async {
    try {
      await supabase.auth.signInWithOAuth(
        provider,
        redirectTo: 'https://app.trailcatch.com://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (error, stack) {
      CrashService.recordError(
        AppError(
          message: 'OAuth Error',
          code: AppErrorCode.signInWithOAuth,
          error: error,
          stack: stack,
        ),
        stack: stack,
      );
    }
  }

  Future<bool> linkWithOAuth(String provider) async {
    appVM.isLinkingAccount = true;

    late OAuthProvider oauthProvider;
    if (provider == 'apple') {
      oauthProvider = OAuthProvider.apple;
    } else if (provider == 'google') {
      oauthProvider = OAuthProvider.google;
    } else if (provider == 'facebook') {
      oauthProvider = OAuthProvider.facebook;
    } else if (provider == 'twitter') {
      oauthProvider = OAuthProvider.twitter;
    } else if (provider == 'github') {
      oauthProvider = OAuthProvider.github;
    } else if (provider == 'discord') {
      oauthProvider = OAuthProvider.discord;
    }

    String providerStr = fnProviderToString(provider);

    try {
      return await supabase.auth.linkIdentity(
        oauthProvider,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (error, stack) {
      CrashService.recordError(
        AppError(
          message: 'Link Auth Error with $providerStr',
          code: AppErrorCode.signInWithOAuth,
          error: error,
          stack: stack,
        ),
        stack: stack,
      );

      return false;
    }
  }

  Future<void> unlinkWithOAuth(String provider) async {
    appVM.isLinkingAccount = false;

    final List<UserIdentity> identities = appVM.auth.identities ?? [];
    final UserIdentity? identity = identities.firstWhereOrNull(
      (element) => element.provider == provider,
    );

    if (identity != null) {
      await supabase.auth.unlinkIdentity(identity);
    }
  }

  //+ users

  Future<void> exchangeCodeForSession(String code) async {
    await supabase.auth.exchangeCodeForSession(code);
  }

  Future<User?> getAuthUser({bool refresh = false}) async {
    if (supabase.auth.currentSession == null) return null;

    return await fnTry(() async {
      if (refresh || supabase.auth.currentSession!.isExpired) {
        try {
          await supabase.auth.refreshSession();
        } catch (error) {
          logger.i(error.toString());
        }
      }

      return supabase.auth.currentSession!.user;
    });
  }

  Future<(String, List<String>)> getUserProviders() async {
    final String provider = appVM.auth.appMetadata['provider'] ?? 'Unknown';
    final List<String> providers0 = List<String>.from(
      appVM.auth.appMetadata['providers'],
    );

    return (provider, providers0);
  }
}
