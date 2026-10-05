import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'features/auth/data/datasources/auth_refresh.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'pages/game_detail_page.dart';
import 'pages/game_settings_page.dart';
import 'pages/home_page.dart';
import 'pages/legal_info_page.dart';
import 'pages/match_page.dart';
import 'pages/settings_page.dart';
import 'pages/splash_page.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  refreshListenable: getIt<AuthRefresh>(),
  redirect: (context, state) {
    final signedIn = getIt<AuthRepository>().hasSession;
    final loc = state.matchedLocation;

    if (loc == '/') {
      return signedIn ? '/home' : '/login';
    }
    if (!signedIn && loc != '/login') {
      return '/login';
    }
    if (signedIn && loc == '/login') {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/games/:gameId',
      builder: (context, state) =>
          GameDetailPage(gameId: state.pathParameters['gameId']!),
      routes: [
        GoRoute(
          path: 'settings',
          builder: (context, state) =>
              GameSettingsPage(gameId: state.pathParameters['gameId']!),
        ),
        GoRoute(
          path: 'matches/new',
          builder: (context, state) =>
              MatchPage(gameId: state.pathParameters['gameId']!),
        ),
        GoRoute(
          path: 'matches/:matchId',
          builder: (context, state) => MatchPage(
            gameId: state.pathParameters['gameId']!,
            matchId: state.pathParameters['matchId'],
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
      routes: [
        GoRoute(
          path: 'about',
          builder: (context, state) =>
              const LegalInfoPage(kind: LegalInfoKind.about),
        ),
        GoRoute(
          path: 'privacy',
          builder: (context, state) =>
              const LegalInfoPage(kind: LegalInfoKind.privacy),
        ),
        GoRoute(
          path: 'terms',
          builder: (context, state) =>
              const LegalInfoPage(kind: LegalInfoKind.terms),
        ),
      ],
    ),
  ],
);
