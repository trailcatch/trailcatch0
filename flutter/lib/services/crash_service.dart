// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trailcatch/constants.dart';

import 'package:trailcatch/getit.dart';
import 'package:trailcatch/logger.dart';
import 'package:trailcatch/services/supabase_service.dart';
import 'package:trailcatch/utils/core_utils.dart';

class CrashService {
  static Future<void> init() async {
    if (cstSentryOn) {
      FlutterError.onError = (FlutterErrorDetails errorDetails) {
        Sentry.captureException(
          errorDetails.exception,
          stackTrace: errorDetails.stack,
        );
      };
    }

    PlatformDispatcher.instance.onError = (error, stack) {
      CrashService.recordError(error, stack: stack);
      return true;
    };
  }

  static void recordFitError(Error error, dynamic stack) async {
    if (cstSentryOn) {
      Sentry.captureException(error, stackTrace: stack);
    }

    logger.e(error.toString, error: error, stackTrace: stack);
  }

  static void recordError(
    dynamic error, {
    StackTrace? stack,
    String? pgFn,
    Map<String, dynamic>? pgParams,
  }) {
    if (error is AuthException) {
      if (error.code == 'flow_state_not_found') {
        supabase.auth.refreshSession();
        return;
      }
    }

    if (CrashService._isErrorOffline(error)) {
      stVM.setOnline(false);
      stVM.addError(AppError(
        message: 'Offline. No internet connection.',
        code: AppErrorCode.offline,
        error: SocketException(error.message),
        stack: stack,
      ));
      return;
    }

    if (error is AppError && error.error == null) {
      stVM.addError(error);
      return;
    }

    if (error is PostgrestException) {
      String msg = error.message;
      msg += ' *** [PG]: fn:$pgFn, params:${jsonEncode(pgParams)}';

      error = AppError(
        message: msg,
        code: AppErrorCode.supaPg,
        error: error,
        stack: stack,
      );
    } else if (error is AuthApiException) {
      error = AppError(
        message: error.message,
        code: AppErrorCode.supaAuth,
        error: error,
        stack: stack,
      );
    } else if (error is StorageException) {
      error = AppError(
        message: error.message,
        code: AppErrorCode.supaStorage,
        error: error,
        stack: stack,
      );
    }

    if (error is AuthException) {
      if (error is AuthRetryableFetchException) {
        if (error.message.startsWith('ClientException with SocketException')) {
          error = AppError(
            message: 'Offline. No internet connection.',
            code: AppErrorCode.offline,
            error: SocketException(error.message),
            stack: stack,
          );
        }
      } else {
        error = AppError(
          message: 'Account not found.',
          code: AppErrorCode.accountNotFound,
          error: error,
          stack: stack,
        );
      }
    }

    if (error is SignInWithAppleAuthorizationException) {
      if (error.code == AuthorizationErrorCode.canceled) {
        logger.i('SignInWithApple canceled by user');
        return;
      } else if (error.code == AuthorizationErrorCode.unknown) {
        if (error.message.contains(
            'com.apple.AuthenticationServices.AuthorizationError error 1000')) {
          return;
        }
      }
    }

    if (error is PlatformException) {
      if (error.code == 'sign_in_failed' &&
          error.message == 'com.google.GIDSignIn') {
        logger.i('SignInWithGoogle canceled by user');
        return;
      }

      if (error.code == '9' && error.message == 'The receipt is missing.') {
        logger.i('Restore Purchases canceled by user');
        return;
      }

      if (error.code == '8' && error.message == 'The receipt is not valid.') {
        logger.i('Restore Purchases canceled by user');
        return;
      }

      if (error.code == 'NotAvailable' &&
          error.details == 'com.apple.LocalAuthentication' &&
          error.message == 'Authentication canceled.') {
        logger.i('Face ID canceled by user');
        return;
      }
    }

    if (CrashService._isErrorOffline(error)) {
      stVM.setOnline(false);
    } else {
      late AppError appError;
      if (error is AppError) {
        appError = error;
      } else {
        appError = AppError(
          message: 'Oops! Looks like something went off trail.',
          code: AppErrorCode.error,
          error: error,
          stack: stack,
        );
      }

      if (stVM.isError && stVM.error?.code == appError.code) {
        return;
      }

      if (cstSentryOn) {
        Sentry.captureException(error, stackTrace: stack);
      }

      if (appError.code == AppErrorCode.supaPg) {
        appError.message = 'Oops! Looks like something went off trail.';
      }

      stVM.addError(appError);
    }
  }

  static bool _isErrorOffline(dynamic error) {
    try {
      Map? details;

      if (error is SocketException) {
        return true;
      }

      if (error.toString().contains('Operation timed out')) {
        return true;
      }

      if (error is PlatformException) {
        if (error.message == 'Operation timed out') {
          return true;
        }
      }

      if (error is AppError && error.error is PlatformException) {
        details = (error.error as PlatformException).details;
      } else {
        details = error.details;
      }

      if (details is Map) {
        if (details['readable_error_code'] == 'OFFLINE_CONNECTION_ERROR' ||
            details['readableErrorCode'] == 'OFFLINE_CONNECTION_ERROR') {
          return true;
        }
      }
    } catch (_) {}

    if (error is AppError && error.error is SocketException) {
      return true;
    }

    // nice catch!
    if (error is SocketException) {
      return true;
    }

    return false;
  }
}
