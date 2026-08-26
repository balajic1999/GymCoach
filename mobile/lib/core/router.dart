import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/exercises/presentation/screens/exercises_screen.dart';
import '../features/workout/presentation/screens/workouts_screen.dart';
import '../features/progress/presentation/screens/progress_screen.dart';
import '../features/ai_coach/presentation/screens/ai_coach_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/exercises/presentation/screens/exercise_detail_screen.dart';
import 'widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/exercises',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ExercisesScreen(),
          ),
        ),
        GoRoute(
          path: '/workouts',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: WorkoutsScreen(),
          ),
        ),
        GoRoute(
          path: '/progress',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProgressScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    ),
    // Full-screen routes (outside shell)
    GoRoute(
      path: '/exercises/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ExerciseDetailScreen(
        exerciseId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/ai-coach',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AiCoachScreen(),
    ),
  ],
);
