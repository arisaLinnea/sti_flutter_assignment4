import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_admin/layout/parking_admin_layout.dart';
import 'package:parking_admin/routes/routes.dart';
import 'package:parking_admin/views/add_parking_lot_view.dart';
import 'package:parking_admin/views/edit_parking_lot_view.dart';
import 'package:parking_admin/views/home_view.dart';
import 'package:parking_admin/views/login_view.dart';
import 'package:parking_admin/views/not_exist_view.dart';
import 'package:parking_admin/views/parking_lot_view.dart';
import 'package:parking_admin/views/parking_stat_view.dart';
import 'package:parking_admin/views/parking_view.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  redirect: (BuildContext context, GoRouterState state) {
    return null; // return "null" to display the intended route without redirecting
  },
  errorBuilder: (context, state) => PageDoesNotExistView(error: state.error),
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.homeRoute.path,
  routes: [
    StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ParkingAdminLayout(
              navigationShell: navigationShell,
            ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.homeRoute.path,
                builder: (context, state) => const HomeView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.parkingLotRoute.path,
                builder: (context, state) => const ParkingLotView(),
                routes: <RouteBase>[
                  // Add child routes
                  GoRoute(
                    path: Routes.editParkingLotRoute.path,
                    builder: (context, state) {
                      final id = state.pathParameters["lotId"]!;
                      return EditParkingLotView(lotId: id);
                    },
                  ),
                  GoRoute(
                    path: Routes.addParkingLotRoute.path,
                    builder: (context, state) {
                      return const AddParkingLotView();
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.parkingRoute.path,
                builder: (context, state) => const ParkingView(),
                routes: const <RouteBase>[],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.statRoute.path,
                builder: (context, state) => const ParkingStatView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.loginRoute.path,
                builder: (context, state) => const LoginView(),
              ),
            ],
          ),
        ])
  ],
);
