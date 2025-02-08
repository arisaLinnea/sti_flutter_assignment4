import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:parking_user/blocs/auth/auth_bloc.dart';
import 'package:parking_user/blocs/notification/notification_bloc.dart';
import 'package:parking_user/blocs/user/user_reg_bloc.dart';
import 'package:parking_user/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_user/firebase_options.dart';
import 'package:parking_user/providers/theme_provider.dart';
import 'package:parking_user/repositories/notification_repository.dart';
import 'package:parking_user/routes/router.dart';
import 'package:parking_user/style/theme.dart';
import 'package:parking_user/views/login_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_client/shared_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: "../.env");
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificationRepository notificationsRepository =
      await NotificationRepository.initialize();

  runApp(MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserLoginRepository>(
          create: (context) => UserLoginRepository(),
        ),
        RepositoryProvider<OwnerRepository>(
          create: (context) => OwnerRepository(),
        ),
      ],
      child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
                create: (context) => AuthBloc(
                    userLoginRepository: context.read<UserLoginRepository>(),
                    ownerRepository: context.read<OwnerRepository>())
                  ..add(AuthUserSubscription())),
            BlocProvider<UserRegBloc>(
                create: (context) => UserRegBloc(
                    userLoginRepository: context.read<UserLoginRepository>(),
                    ownerRepository: context.read<OwnerRepository>())),
            BlocProvider<NotificationBloc>(
                create: (context) =>
                    NotificationBloc(notRepository: notificationsRepository)),
          ],
          child: ChangeNotifierProvider<ThemeNotifier>(
            create: (_) => ThemeNotifier(),
            child: const FindMeASpot(),
          ))));
}

class FindMeASpot extends StatelessWidget {
  const FindMeASpot({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      home: const AuthViewSwitcher(),
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
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticatedState) {
            return const UserView();
          } else {
            return const LoginView();
          }
        },
      ),
    ));
  }
}

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<VehicleRepository>(
            create: (context) => VehicleRepository(),
          ),
          RepositoryProvider<ParkingLotRepository>(
            create: (context) => ParkingLotRepository(),
          ),
          RepositoryProvider<ParkingRepository>(
            create: (context) => ParkingRepository(),
          ),
        ],
        child: MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (context) => VehicleBloc(
                      vehicleRepository: context.read<VehicleRepository>(),
                      authBloc: context.read<AuthBloc>())
                    ..add(SubscribeToUserVehicles(
                        userId: (context.read<AuthBloc>().state
                                as AuthAuthenticatedState)
                            .user
                            .id))),
              BlocProvider(
                  create: (context) => ParkingLotBloc(
                      parkingLotRepository:
                          context.read<ParkingLotRepository>(),
                      parkingRepository: context.read<ParkingRepository>())
                    ..add(SubscribeToParkingLots())),
              BlocProvider(
                  create: (context) =>
                      ParkingBloc(parkingRepository: ParkingRepository())
                        ..add(SubscribeToParkings())),
            ],
            child: Consumer<ThemeNotifier>(
              builder: (context, themeNotifier, child) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  routerConfig: router,
                  title: 'Find Me A Spot',
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: themeNotifier.themeMode,
                );
              },
            )));
  }
}
