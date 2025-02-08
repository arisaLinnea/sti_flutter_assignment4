import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_admin/blocs/auth/auth_bloc.dart';
import 'package:parking_admin/firebase_options.dart';
import 'package:parking_admin/providers/theme_provider.dart';
import 'package:parking_admin/routes/router.dart';
import 'package:parking_admin/style/theme.dart';
import 'package:parking_admin/views/login_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_client/shared_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: "../.env");
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(
            create: (context) => ParkingLotBloc(
                parkingLotRepository: ParkingLotRepository(),
                parkingRepository: ParkingRepository())
              ..add(SubscribeToParkingLots())),
        BlocProvider(
            create: (context) =>
                ParkingBloc(parkingRepository: ParkingRepository())
                  ..add(SubscribeToParkings())),
      ],
      child: ChangeNotifierProvider<ThemeNotifier>(
        create: (_) => ThemeNotifier(),
        child: const FindMeASpotAdmin(),
      )));
}

class FindMeASpotAdmin extends StatelessWidget {
  const FindMeASpotAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthViewSwitcher(),
    );
  }
}

class AuthViewSwitcher extends StatelessWidget {
  const AuthViewSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
          if (state is AuthAuthenticatedState) {
            return const NavRailView();
          } else {
            return const LoginView();
          }
        }),
      ),
    );
  }
}

class NavRailView extends StatefulWidget {
  const NavRailView({super.key});

  @override
  State<NavRailView> createState() => _NavRailViewState();
}

class _NavRailViewState extends State<NavRailView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          title: 'Find Me A Spot Admin',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.themeMode,
        );
      },
    );
  }
}
