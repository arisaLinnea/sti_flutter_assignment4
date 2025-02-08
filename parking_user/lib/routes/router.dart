import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_user/layout/parking_layout.dart';
import 'package:parking_user/routes/routes.dart';
import 'package:parking_user/views/add_vehicle_view.dart';
import 'package:parking_user/views/edit_vehicle_view.dart';
import 'package:parking_user/views/home_view.dart';
import 'package:parking_user/views/new_parking_view.dart';
import 'package:parking_user/views/parking_view.dart';
import 'package:parking_user/views/vehicle_view.dart';
import 'package:shared_client/shared_client.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  redirect: (BuildContext context, GoRouterState state) {
    return null;
  },
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.homeRoute.path,
  routes: [
    StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ParkingLayout(
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
                path: Routes.vehicleRoute.path,
                builder: (context, state) => const VehicleView(),
                routes: <RouteBase>[
                  // Add child routes
                  GoRoute(
                    path: Routes.addVehicleRoute.path,
                    builder: (context, state) {
                      return const AddVehicleView();
                    },
                  ),
                  GoRoute(
                    path: Routes.editVehicleRoute.path,
                    builder: (context, state) {
                      final id = state.pathParameters["vehicleId"]!;
                      return EditVehicleView(vehicleId: id);
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
                routes: <RouteBase>[
                  // Add child routes
                  GoRoute(
                    path: Routes.addParkingRoute.path,
                    builder: (context, state) {
                      // final id = state.pathParameters["id"];
                      final lot = state.extra! as ParkingLot;
                      return NewParkingView(lot: lot);
                    },
                  ),
                ],
              ),
            ],
          ),
        ])
  ],
);
