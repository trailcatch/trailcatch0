// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:trailcatch/context.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/screens/about/sheet/demo_sheet.dart';
import 'package:trailcatch/screens/profile/sheets/profile_dog_breed_card_sheet.dart';
import 'package:trailcatch/screens/root/error404_screen.dart';
import 'package:trailcatch/screens/root/sheets/error404_bug_sheet.dart';
import 'package:trailcatch/screens/root/sheets/error404_contacts_sheet.dart';
import 'package:trailcatch/screens/settings/sheets/settings_subscription_premium_sheet.dart';
import 'package:trailcatch/screens/settings/sheets/settings_subscription_trial_sheet.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/widgets/scaffolds/popup_scaffold.dart';
import 'package:trailcatch/screens/about/sheet/about_lusi_sheet.dart';
import 'package:trailcatch/screens/devices/devices_screen.dart';
import 'package:trailcatch/screens/devices/devices_sync_screen.dart';
import 'package:trailcatch/screens/devices/sheets/devices_fit_error_sheet.dart';
import 'package:trailcatch/screens/devices/sheets/devices_fit_sheet.dart';
import 'package:trailcatch/screens/devices/sheets/devices_trail_exists_sheet.dart';
import 'package:trailcatch/screens/notifications/sheets/notifs_users_sheet.dart';
import 'package:trailcatch/screens/profile/profile_your_city_screen.dart';
import 'package:trailcatch/screens/profile/sheets/profile_month_trails_sheet.dart';
import 'package:trailcatch/screens/profile/sheets/profile_top_likes_sheet.dart';
import 'package:trailcatch/screens/radar/sheets/radar_empty_your_city_sheet.dart';
import 'package:trailcatch/screens/radar/sheets/radar_search_sheet.dart';
import 'package:trailcatch/screens/root/demo_screen.dart';
import 'package:trailcatch/screens/root/fcm_screen.dart';
import 'package:trailcatch/screens/root/init_screen.dart';
import 'package:trailcatch/screens/root/join_screen.dart';
import 'package:trailcatch/screens/notifications/notifications_screen.dart';
import 'package:trailcatch/screens/about/about_screen.dart';
import 'package:trailcatch/screens/root/pin_screen.dart';
import 'package:trailcatch/screens/root/ttr_screen.dart';
import 'package:trailcatch/screens/settings/settings_delete_account_screen.dart';
import 'package:trailcatch/screens/root/splash_screen.dart';
import 'package:trailcatch/screens/profile/profile_dog_breeds_screen.dart';
import 'package:trailcatch/screens/settings/settings_delete_last_account_screen.dart';
import 'package:trailcatch/screens/settings/settings_faceid_screen.dart';
import 'package:trailcatch/screens/settings/settings_linked_accounts_screen.dart';
import 'package:trailcatch/screens/devices/sheets/devices_garmin_sheet.dart';
import 'package:trailcatch/screens/devices/sheets/devices_polar_sheet.dart';
import 'package:trailcatch/screens/devices/sheets/devices_suunto_sheet.dart';
import 'package:trailcatch/screens/trails/sheets/trail_not_allow_pub_sheet.dart';
import 'package:trailcatch/screens/trails/sheets/trail_share_sheet.dart';
import 'package:trailcatch/screens/trails/sheets/trail_with_dogs_sheet.dart';
import 'package:trailcatch/screens/trails/trail_card_screen.dart';
import 'package:trailcatch/screens/settings/settings_language_screen.dart';
import 'package:trailcatch/screens/profile/sheets/profile_dog_birthday_sheet.dart';
import 'package:trailcatch/screens/profile/sheets/profile_dog_death_sheet.dart';
import 'package:trailcatch/screens/profile/profile_edit_screen.dart';
import 'package:trailcatch/screens/profile/profile_rlship_screen.dart';
import 'package:trailcatch/screens/profile/profile_statistics_screen.dart';
import 'package:trailcatch/screens/settings/settings_subscription_screen.dart';
import 'package:trailcatch/screens/profile/profile_countries_screen.dart';
import 'package:trailcatch/screens/profile/profile_screen.dart';
import 'package:trailcatch/screens/root/root_screen.dart';
import 'package:trailcatch/screens/profile/profile_contacts_screen.dart';
import 'package:trailcatch/screens/trails/trails_screen.dart';
import 'package:trailcatch/widgets/sheets/age_groups_sheet.dart';
import 'package:trailcatch/widgets/sheets/status_sheet.dart';
import 'package:trailcatch/screens/profile/sheets/profile_birthday_sheet.dart';
import 'package:trailcatch/screens/settings/settings_notifications_screen.dart';
import 'package:trailcatch/screens/trails/sheets/trail_likes_sheet.dart';
import 'package:trailcatch/screens/trails/sheets/trail_filters_sheet.dart';
import 'package:trailcatch/screens/settings/settings_screen.dart';

typedef AppRouteArgs = Map<String, dynamic>;
typedef AppSheetRouteFn = Widget? Function(String name, AppRouteArgs? args);

class AppPopupAction {
  AppPopupAction(
    this.text,
    this.func, {
    this.color,
    this.selected = false,
  });

  final String text;
  final Future<dynamic> Function() func;
  final Color? color;
  final bool selected;
}

abstract class AppRoute {
  static late List<SingleChildWidget> providers;

  static late Function appNav;

  static RouteFactory mainRoutes = (RouteSettings settings) {
    AppRouteArgs args = settings.arguments as AppRouteArgs? ?? {};

    switch (settings.name) {
      case '/splash':
        return AppRoute.fadeTo(const SplashScreen());
      case '/init':
        return AppRoute.fadeTo(const InitScreen());
      case '/join':
        return AppRoute.routeTo(const JoinScreen());
      case '/pin':
        return AppRoute.fadeTo(PinScreen(
          canGoBack: args['canGoBack'],
          showPinDesc: args['showPinDesc'],
        ));
      case '/demo':
        return AppRoute.routeTo(const DemoScreen());
      case '/error404':
        return AppRoute.routeTo(const Error404Screen());

      case '/fcm':
        return AppRoute.fadeTo(const FcmScreen());
      case '/ttr':
        return AppRoute.fadeTo(const TtrScreen());

      // --

      case '/root':
        return AppRoute.fadeTo(const RootScreen());

      // --

      case '/profile':
        return AppRoute.routeTo(ProfileScreen(
          user: args['user'],
          userId: args['userId'],
        ));
      case '/profile_edit':
        return AppRoute.routeTo(const ProfileEditScreen());
      case '/profile_your_city':
        return AppRoute.routeTo(const ProfileYourCityScreen());
      case '/profile_countries':
        return AppRoute.routeTo(ProfileCountriesScreen(
          uiso3s: args['uiso3s'],
          multiSelect: args['multiSelect'],
        ));
      case '/profile_dogs_breed':
        return AppRoute.routeTo(ProfileDogsBreedScreen(
          dogsBreed: args['dogsBreed'],
          multiSelect: args['multiSelect'],
          justView: args['justView'],
        ));
      case '/profile_contacts':
        return AppRoute.routeTo(ProfileContactsScreen(
          contacts: args['contacts'],
        ));
      case '/profile_statistics':
        return AppRoute.routeTo(
          ProfileStatisticsScreen(
            user: args['user'],
            year: args['year'],
          ),
        );

      case '/profile_rlship':
        return AppRoute.routeTo(
          ProfileRlshipScreen(
            user: args['user'],
            subscriptions: args['subscriptions'],
            hiddens: args['hiddens'],
          ),
        );

      // --

      case '/settings':
        return AppRoute.routeTo(const SettingsScreen());
      case '/settings_language':
        return AppRoute.routeTo(const SettingsLanguageScreen());
      case '/settings_subscription':
        return AppRoute.routeTo(const SettingsSubscriptionScreen());
      case '/settings_notifications':
        return AppRoute.routeTo(const SettingsNotificationsScreen());
      case '/settings_faceid':
        return AppRoute.routeTo(const SettingsFaceIdScreen());
      case '/settings_linked_accounts':
        return AppRoute.routeTo(const SettingsLinkedAccountsScreen());

      case '/settings_delete_account':
        return AppRoute.routeTo(const SettingsDeleteAccountScreen());
      case '/settings_delete_last_account':
        return AppRoute.routeTo(const SettingsDeleteLastAccountScreen());

      // --

      case '/notifications':
        return AppRoute.routeTo(const NotificationsScreen());

      // --

      case '/trails':
        return AppRoute.routeTo(const TrailsScreen());
      case '/trail_card':
        return AppRoute.routeTo(TrailCardScreen(
          trailExt: args['trailExt'],
          trailId: args['trailId'],
        ));

      // --

      case '/devices':
        return AppRoute.routeTo(const DevicesScreen());
      case '/devices_sync':
        return AppRoute.routeTo(DevicesSyncScreen(
          deviceId: args['deviceId'],
        ));

      // --

      case '/about':
        return AppRoute.routeTo(const AboutScreen());

      default:
        return AppRoute.fadeTo(const InitScreen());
    }
  };

  static Widget? Function(String name, AppRouteArgs args) sheetRoutes = (
    String name, [
    AppRouteArgs args = const {},
  ]) {
    switch (name) {
      case '/profile_birthday':
        return ProfileBirthdaySheet(birthday: args['birthday']);
      case '/profile_dog_birthday':
        return ProfileDogBirthdaySheet(birthday: args['birthday']);
      case '/profile_dog_death':
        return ProfileDogDeathSheet(death: args['death']);
      case '/profile_month_trails':
        return ProfileMonthTrailsSheet(
          user: args['user'],
          monthAt: args['monthAt'],
        );
      case '/profile_top_likes':
        return ProfileTopLikesSheet(
          user: args['user'],
        );

      case '/profile_dog_breed_card':
        return ProfileDogBreedCardSheet(
          wikiDog: args['wikiDog'],
          selected: args['selected'],
          onSelect: args['onSelect'],
        );

      // --

      case '/settings_subscription_premium':
        return SettingsSubscriptionPremiumSheet(
          premiumPrice: args['premiumPrice'],
        );
      case '/settings_subscription_trial':
        return SettingsSubscriptionTrialSheet();

      // --

      case '/trail_filters':
        return TrailFiltersSheet(showFltStranges: args['showFltStranges']);

      case '/trail_likes':
        return TrailLikesSheet(
          trail: args['trail'],
        );
      case '/trail_with_dogs':
        return TrailWithDogsSheet(trailExt: args['trailExt']);

      case '/trail_share':
        return TrailShareSheet(trail: args['trail']);

      case '/trail_not_allow_pub':
        return const TrailNotAllowPubSheet();

      // --

      case '/notifs_users':
        return NotifsUsersSheet(
          notifsExt: args['notifsExt'],
        );

      // --

      case '/radar_search':
        return const RadarSearchSheet();
      case '/radar_empty_your_city':
        return const RadarEmptyYourCitySheet();

      // --

      case '/about_lusi':
        return const AboutLusiSheet();
      case '/demo':
        return const DemoSheet();

      case '/error404_support':
        return const Error404ContactsSheet();
      case '/error404_bug':
        return const Error404BugSheet();

      // --

      case '/age_groups':
        return AgeGroupsSheet(ageGroup: args['ageGroup']);

      // --

      case '/devices_garmin':
        return const DevicesGarminSheet();
      case '/devices_suunto':
        return const DevicesSuuntoSheet();
      case '/devices_polar':
        return const DevicesPolarSheet();
      case '/devices_fit':
        return const DevicesFitSheet();
      case '/devices_fit_error':
        return const DevicesFitErrorSheet();
      case '/devices_trail_exists':
        return DevicesTrailExistsSheet(trailId: args['trailId']);

      // --

      case '/status':
        return const StatusSheet();

      default:
        return null;
    }
  };

  // INTF

  static Future goTo(String name, {AppRouteArgs? args}) async {
    if (stVM.isError && name != '/init' && name != '/error404') {
      stVM.clearError(silence: true);
    }

    return await AppRoute.appNav().pushNamed(name, arguments: args);
  }

  static Future<void> goBack([dynamic val]) async {
    stVM.clearError(silence: false);

    await AppRoute.appNav().maybePop(val);
  }

  static Future goSheetTo(String name, {AppRouteArgs args = const {}}) async {
    final skipErRoute = ['/status', '/error404_bug', '/error404_support'];
    if (!skipErRoute.contains(name)) {
      stVM.clearError(silence: true);
    }

    final Widget? widget = sheetRoutes(name, args);
    if (widget == null) return null;

    return await routeToSheetBottom(widget);
  }

  static Future<dynamic> goSheetBack([dynamic val]) async {
    return Navigator.of(appContext).maybePop(val);
  }

  // ETC

  static MaterialPageRoute routeTo(Widget widget) {
    return MaterialPageRoute(
      builder: (c) => MultiProvider(
        providers: AppRoute.providers,
        child: MediaQuery(
          data: AppTheme.mediaQuery(c),
          child: widget,
        ),
      ),
    );
  }

  static PageRouteBuilder fadeTo(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (c, a1, a2) => MultiProvider(
        providers: AppRoute.providers,
        child: MediaQuery(
          data: AppTheme.mediaQuery(c),
          child: widget,
        ),
      ),
      transitionsBuilder: (c, anim, a2, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  static Future<T?> routeToSheetBottom<T>(Widget widget) async {
    return showModalBottomSheet(
      context: appContext,
      elevation: 10,
      isScrollControlled: true,
      backgroundColor: AppTheme.clBlack,
      enableDrag: true,
      builder: (_) => widget,
    );
  }

  //

  static Future<T?> showPopup<T>(
    List<AppPopupAction> actions, {
    String? title,
    List<AppPopupAction>? bottoms,
  }) async {
    return showCupertinoModalPopup<T>(
      context: appContext,
      builder: (BuildContext context) => AppPopupScaffold(
        actions: actions,
        title: title,
        bottoms: bottoms,
      ),
    );
  }
}
