// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:trailcatch/constants.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/screens/root/splash_screen.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/services/crash_service.dart';
import 'package:trailcatch/services/firebase_service.dart';
import 'package:trailcatch/services/supabase_service.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/viewmodels/app_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupGetIt();

  await dotenv.load();
  await appVM.initLang();

  await FirebaseService.init();
  await CrashService.init();
  await SupabaseService.init();

  await storageServ.init();

  if (cstSentryOn) {
    await SentryFlutter.init(
      (options) {
        options.dsn = cstSentryDsn;
        options.tracesSampleRate = 1.0;
        options.profilesSampleRate = 1.0;
      },
      appRunner: () => runApp(const MyApp()),
    );
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    AppRoute.providers = [
      ChangeNotifierProvider(create: (_) => appVM),
      ChangeNotifierProvider(create: (_) => stVM),
      ChangeNotifierProvider(create: (_) => trailVM),
      ChangeNotifierProvider(create: (_) => deviceVM),
      ChangeNotifierProvider(create: (_) => notifVM),
    ];

    AppRoute.appNav = () => _navigatorKey.currentState as NavigatorState;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugInvertOversizedImages = false;

    return MultiProvider(
      providers: AppRoute.providers,
      child: Builder(builder: (context) {
        context.watch<AppViewModel>();

        return MaterialApp(
          key: GlobalKey(),
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.get(),
          onGenerateRoute: AppRoute.mainRoutes,
          home: const SplashScreen(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale(appVM.lang),
        );
      }),
    );
  }
}
