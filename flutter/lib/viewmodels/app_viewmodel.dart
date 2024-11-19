// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:collection/collection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:ios_open_subscriptions_settings/ios_open_subscriptions_settings.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qonversion_flutter/qonversion_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:trailcatch/services/crash_service.dart';
import 'package:trailcatch/services/supabase_service.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/models/location_model.dart';
import 'package:trailcatch/utils/location_utils.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/utils/pref_utils.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/viewmodels/base_viewmodel.dart';

class AppViewModel extends BaseViewModel {
  int _tab = 0;
  int get tab => _tab;
  set tab(int val) {
    _tab = val;
    notify();
  }

  String _lang = 'en';
  String get lang => _lang;

  late String _appVersion;
  String get appVersion => _appVersion;

  User? _auth;
  User get auth => _auth!;
  bool get isAuthExists => _auth != null;

  (String, List<String>)? _authProviders;
  (String, List<String>)? get authProviders => _authProviders;

  UserModel? _user;
  UserModel get user => _user!;
  bool get isUserExists => _user != null;

  UserSettingsModel? _settings;
  UserSettingsModel get settings => _settings ?? UserSettingsModel.empty();

  LocationModel? _yourCity;
  LocationModel? get yourCity => _yourCity;
  void setYourCity(LocationModel? val) {
    _yourCity = val;

    if (val == null) {
      fnPrefClearYourCity();
    } else {
      fnPrefSaveYourCity(val.city);
    }
  }

  // --

  QProduct? _product;
  QProduct? get product => _product;

  QEntitlement? _plan;
  QEntitlement? get plan => _plan;

  // --

  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> get countries => _countries;

  List<LocationModel> _cities = [];
  List<LocationModel> get cities => _cities;

  List<Map<String, dynamic>> _wikiDogs = [];
  List<Map<String, dynamic>> get wikiDogs => _wikiDogs;

  List<Map<String, dynamic>> wikiDogsData = [];

  // --

  late VoidCallback reInitRadarPos;
  bool isSingingAccount = false;
  bool isLinkingAccount = false;

  String? appleGivenName;
  String? appleFamilyName;
  String? appleEmail;

  bool showPinDesc = false;
  bool showFcmDesc = false;
  bool showTtrDesc = false;

  // --

  Future<void> init1() async {
    Future<void> reInit1({User? auth}) async {
      await reAuthMyself(auth: auth);
      await reFetchMyself();
      await reFetchSettings();
      await deviceVM.reInit();
      await trailVM.reInitTrails();
      await goToPin();
    }

    AppLinks().uriLinkStream.listen((uri) async {
      if (uri.path == '//login-callback') {
        if (uri.queryParameters.containsKey('code')) {
          await fnTry(() async {
            await authServ.exchangeCodeForSession(uri.queryParameters['code']!);
          });
        }
      } else if (uri.path.startsWith('/u/')) {
        await fnTry(() async {
          String userId = fnDecodeAES(uri.path.substring(3));

          AppRoute.goTo('/profile', args: {
            'userId': userId,
          });
        });
      } else if (uri.path.startsWith('/t/')) {
        String trailId = fnDecodeAES(uri.path.substring(3));

        AppRoute.goTo('/trail_card', args: {
          'trailId': trailId,
        });
      }
    });

    authServ.onAuthStateChange().listen((AuthState state) async {
      switch (state.event) {
        case AuthChangeEvent.signedIn:
          if (!isLinkingAccount) {
            await reInit1(auth: state.session?.user);
          } else {
            isLinkingAccount = false;
            await reAuthMyself(auth: state.session?.user);
          }

          break;
        case AuthChangeEvent.userUpdated:
          await reAuthMyself(auth: state.session?.user);
          await reFetchMyself();
          await reFetchSettings();

          break;
        default:
          0;
      }
    });

    await fnTry(() async {
      PackageInfo.fromPlatform().then((packageInfo) {
        _appVersion = packageInfo.version;
      });

      _countries = List<Map<String, dynamic>>.from(jsonDecode(
        await rootBundle.loadString(
          'assets/***/countries.json',
        ),
      ));

      _cities = await fnLoadWorldCities();
      final String yourCityStr = await fnPrefGetYourCity();
      if (yourCityStr.isNotEmpty) {
        _yourCity = _cities.firstWhereOrNull((cts) => cts.city == yourCityStr);
      }

      _wikiDogs = List<Map<String, dynamic>>.from(jsonDecode(
        await rootBundle.loadString(
          'assets/***/dogs.json',
        ),
      ));

      await reAppleCreds();
    });

    isLinkingAccount = false;

    await reInit1();
  }

  Future<void> reAuthMyself({User? auth, bool refresh = false}) async {
    _auth = auth ?? await authServ.getAuthUser(refresh: refresh);
    if (_auth != null) {
      _authProviders = await authServ.getUserProviders();
    }
  }

  Future<void> reFetchMyself() async {
    if (isAuthExists) {
      _user = await userServ.fnUsersFetch(userId: _auth!.id);
    }
  }

  Future<void> reFetchSettings() async {
    if (isUserExists) {
      await fnTry(() async {
        _settings = await userServ.fnUsersSettingsFetch();

        if (_settings != null) {
          notifVM.reFetchNotifs();

          if (_settings!.lang != appVM.lang && _settings!.lang.isNotEmpty) {
            appVM.setLang(_settings!.lang, silence: true);

            fnPrefSaveLang(_settings!.lang);
            userServ.fnUsersUpdate(lang: _settings!.lang);
          }

          final (provider, _) = await authServ.getUserProviders();
          if (provider != 'Unknown') {
            _settings!.provider = provider;
          }
        }
      });
    }
  }

  Future<void> goToPin() async {
    if (fnIsDemo()) {
      await goToRoot();
      return;
    }

    if (isUserExists && _settings != null) {
      if (showPinDesc || await _settings!.isFaceIdRequired()) {
        final isOk = await AppRoute.goTo('/pin', args: {
          'canGoBack': false,
          'showPinDesc': showPinDesc,
        });

        if (isOk ?? true) {
          // pass
        } else {
          return;
        }
      }
    }

    await goToRoot();
  }

  Future<void> goToRoot() async {
    if (isUserExists) {
      if (!fnIsDemo()) {
        if (showFcmDesc) {
          await AppRoute.goTo('/fcm');
        } else {
          await initFCM();
        }

        if (showTtrDesc) {
          await AppRoute.goTo('/ttr');
        } else {
          await initTrackTr();
        }
      }

      AppRoute.goTo('/root');

      await initOfferings();
      await refreshPurchases();
    } else {
      if (isAuthExists && !stVM.isError) {
        AppRoute.goTo('/profile_edit');
      } else {
        if (stVM.error?.code == AppErrorCode.error) {
          AppRoute.goTo('/error404');
        } else {
          AppRoute.goTo('/init');
        }
      }
    }

    appVM.isSingingAccount = false;
  }

  //+ purchases

  Future<void> initOfferings() async {
    await fnTry(() async {
      final config = QonversionConfigBuilder(
        '***',
        QLaunchMode.subscriptionManagement,
      ).build();

      Qonversion.initialize(config);

      final QOfferings offerings =
          await Qonversion.getSharedInstance().offerings();

      if (offerings.main != null && offerings.main!.products.isNotEmpty) {
        _product = offerings.main!.products.first;
      } else {
        Sentry.captureException(AppError(
          message: 'Qonversion products are empty.',
          code: AppErrorCode.qonversion,
        ));
      }
    });
  }

  Future<void> refreshPurchases() async {
    await fnTry(() async {
      final Map<String, QEntitlement> entitlements =
          await Qonversion.getSharedInstance().checkEntitlements();

      final plan = entitlements['tc_premium_plan'];
      if (plan != null && plan.isActive) {
        switch (plan.renewState) {
          case QEntitlementRenewState.willRenew:
          case QEntitlementRenewState.nonRenewable:
            // .willRenew is the state of an auto-renewable subscription
            // .nonRenewable is the state of consumable/non-consumable IAPs that could unlock lifetime access
            _plan = plan;
            break;
          case QEntitlementRenewState.billingIssue:
            // Grace period: entitlement is active, but there was some billing issue.
            // Prompt the user to update the payment method.
            _plan = null;
            break;
          case QEntitlementRenewState.canceled:
            // The user has turned off auto-renewal for the subscription, but the subscription has not expired yet.
            // Prompt the user to resubscribe with a special offer.
            _plan = null;
            break;
          default:
            _plan = null;
            break;
        }
      } else {
        _plan = null;
      }
    });
  }

  Future<void> restorePurchases() async {
    await fnTry(() async {
      await Qonversion.getSharedInstance().restore();

      await Future.delayed(500.mlsec);
      await refreshPurchases();

      notify();
    });
  }

  Future<void> purchasePremium() async {
    try {
      if (_product != null) {
        await Qonversion.getSharedInstance().purchaseProduct(
          _product!,
        );

        await Future.delayed(500.mlsec);
        await refreshPurchases();
      }
    } on QPurchaseException catch (error, stack) {
      if (error.isUserCancelled) {
        return;
      } else {
        CrashService.recordError(error, stack: stack);
      }
    } catch (error, stack) {
      CrashService.recordError(error, stack: stack);
    }
  }

  Future<void> cancelPurchase() async {
    await fnTry(() async {
      await IosOpenSubscriptionsSettings.openSubscriptionsSettings();

      await Future.delayed(500.mlsec);
      await refreshPurchases();
      notify();
    });
  }

  Future<void> startTrial() async {
    await fnTry(() async {
      if (_settings != null) {
        final now = DateTime.now();

        _settings!.trialAt = now;
        await userServ.fnUsersUpdate(trialAt: now);

        notify();
      }
    });
  }

  //+ FCM

  Future<void> initFCM() async {
    if (fnIsDemo()) return;

    await fnTry(() async {
      final NotificationSettings notifSettings =
          await FirebaseMessaging.instance.requestPermission();

      if (notifSettings.alert == AppleNotificationSetting.disabled) {
        if (settings.notifPushLikes || settings.notifPushSubscribers) {
          await userServ.fnUsersUpdate(
            notifPushLikes: false,
            notifPushSubscribers: false,
          );

          _settings = await userServ.fnUsersSettingsFetch();
        }
      }

      if (!appVM.user.isDemo) {
        final fcmToken = await fbServ.fcmToken();
        if (fcmToken != settings.fcmToken && fcmToken.isNotEmpty) {
          await userServ.fnUsersUpdate(fcmToken: fcmToken);
          settings.fcmToken = fcmToken;
        }
      }

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessageOpenedApp.listen((
        RemoteMessage message,
      ) async {
        AppRoute.goTo('/notifications');
      });
    });
  }

  //+ tracking transparency

  Future<void> initTrackTr() async {
    await fnTry(() async {
      final TrackingStatus status =
          await AppTrackingTransparency.requestTrackingAuthorization();

      if (status == TrackingStatus.authorized) {
        if (!settings.appTrackingTransparency) {
          userServ.fnUsersUpdate(appTrackingTransparency: true);
        }
      } else if (status == TrackingStatus.denied) {
        if (settings.appTrackingTransparency) {
          userServ.fnUsersUpdate(appTrackingTransparency: false);

          if (_settings != null) {
            _settings!.appTrackingTransparency = false;
          }
        }
      }
    });
  }

  //+ lang

  Future<void> initLang() async {
    fnTry(() async {
      final String prefLang = await fnPrefGetLang();
      if (prefLang.isNotEmpty) {
        setLang(prefLang, silence: true);
      } else {
        final String? deviceLang = fnDeviceLang();
        if (deviceLang != null) {
          setLang(deviceLang, silence: true);
        }
      }
    });
  }

  void setLang(String val, {bool silence = false}) {
    if (val == _lang || val.isEmpty) return;

    Set<String> codes = AppLocalizations.supportedLocales.map((it) {
      return it.languageCode;
    }).toSet();

    if (codes.contains(val)) {
      _lang = val;

      if (!silence) notify();
    }
  }

  //+ profiles

  Future<void> shareProfile(UserModel user) async {
    await fnTry(() async {
      final String encrUserId = fnEncodeAES(user.userId);

      final String text =
          'Find Me on TrailCatch - https://app.trailcatch.com/u/$encrUserId';
      await Share.share(text, subject: 'TrailCatch\n$text');
    });
  }

  Future<void> subscribeUser(UserModel user) async {
    user.rlship = 1;

    user.subscribers += 1;
    appVM.user.subscriptions += 1;

    await userServ.fnUsersRelationship(
      userId: user.userId,
      rlship: 1,
    );
  }

  Future<void> hideUser(UserModel user) async {
    user.rlship = 0;

    if (user.subscribers > 0) user.subscribers -= 1;
    if (appVM.user.subscriptions > 0) appVM.user.subscriptions -= 1;

    await userServ.fnUsersRelationship(
      userId: user.userId,
      rlship: null,
    );

    await userServ.fnUsersRelationship(
      userId: user.userId,
      rlship: 0,
    );
  }

  Future<void> removeRlshipUser(UserModel user) async {
    user.rlship = null;

    if (user.subscribers > 0) user.subscribers -= 1;
    if (appVM.user.subscriptions > 0) appVM.user.subscriptions -= 1;

    await userServ.fnUsersRelationship(
      userId: user.userId,
      rlship: null,
    );
  }

  //+ trails

  Future<void> shareTrail(TrailModel trail) async {
    if (trail.isEmpt) return;

    AppRoute.goSheetTo('/trail_share', args: {
      'trail': trail,
    });
  }

  //+ apple creda

  Future<void> reAppleCreds() async {
    final creds = await fnPrefGetAppleCreds();
    if (creds.isNotEmpty) {
      appVM.appleGivenName = creds['givenName'];
      appVM.appleFamilyName = creds['familyName'];
      appVM.appleEmail = creds['email'];
    }
  }

  //+ sign out

  Future<void> signOut() async {
    trailVM.trailFilters.clear();
    trailVM.feedTrailsExt.clear();
    trailVM.feedFltTrailsExt.clear();
    trailVM.nearTrailsExt.clear();
    trailVM.myTrailsExt.clear();

    final appleCreds = await fnPrefGetAppleCreds();
    await fnPrefClearAll();
    await fnPrefSaveAppleCreds(appleCreds);

    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}

    try {
      final (provider, _) = await authServ.getUserProviders();
      await fnPrefSaveLastLogin(provider);
    } catch (_) {}

    try {
      await supabase.auth.signOut();

      // supabase issue with re-login, need do it twice
      await supabase.auth.signOut();
    } catch (_) {}

    _auth = null;
    _user = null;
    _settings = null;

    await AppRoute.goTo('/init');
  }

  Future<void> deleteAccount() async {
    trailVM.trailFilters.clear();
    trailVM.feedTrailsExt.clear();
    trailVM.feedFltTrailsExt.clear();
    trailVM.nearTrailsExt.clear();
    trailVM.myTrailsExt.clear();

    final appleCreds = await fnPrefGetAppleCreds();
    await fnPrefClearAll();
    await fnPrefSaveAppleCreds(appleCreds);

    await FirebaseMessaging.instance.deleteToken();
    await userServ.fnUsersDelete();

    await supabase.auth.signOut();

    _auth = null;
    _user = null;
    _settings = null;

    // here we go to Farewell Message
  }
}
