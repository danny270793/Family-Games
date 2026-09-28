import 'package:family_games/core/auth/auth_refresh.dart';
import 'package:family_games/core/auth/auth_repository.dart';
import 'package:family_games/pages/game_detail_page.dart';
import 'package:family_games/pages/game_settings_page.dart';
import 'package:family_games/pages/home_page.dart';
import 'package:family_games/pages/legal_info_page.dart';
import 'package:family_games/pages/login_page.dart';
import 'package:family_games/pages/match_page.dart';
import 'package:family_games/pages/settings_page.dart';
import 'package:family_games/pages/splash_page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthRefresh authRefresh) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final signedIn = authRepository.currentSession != null;
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
}
