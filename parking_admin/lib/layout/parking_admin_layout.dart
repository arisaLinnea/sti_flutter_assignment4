import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_admin/blocs/auth/auth_bloc.dart';
import 'package:parking_admin/providers/theme_provider.dart';
import 'package:parking_admin/routes/navigation.dart';
import 'package:parking_admin/views/home_view.dart';
import 'package:provider/provider.dart';

class ParkingAdminLayout extends StatelessWidget {
  ParkingAdminLayout({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  late Widget view = const HomeView();
  NavigationRailLabelType labelType = NavigationRailLabelType.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (int index) {
              navigationShell.goBranch(index);
            },
            labelType: labelType,
            destinations: destinations,
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: actionButtons(context),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // This is the main content.
          Expanded(child: navigationShell)
        ],
      ),
    );
  }

  Column actionButtons(BuildContext context) {
    return Column(children: [
      IconButton(
        icon: const Icon(Icons.person),
        onPressed: () => context.read<AuthBloc>().add(AuthLogoutEvent()),
      ),
      IconButton(
        icon: const Icon(Icons.brightness_6),
        onPressed: () {
          ThemeNotifier themeNotifier =
              Provider.of<ThemeNotifier>(context, listen: false);
          if (themeNotifier.themeMode == ThemeMode.light) {
            themeNotifier.setTheme(ThemeMode.dark);
          } else {
            themeNotifier.setTheme(ThemeMode.light);
          }
        },
      ),
    ]);
  }
}
