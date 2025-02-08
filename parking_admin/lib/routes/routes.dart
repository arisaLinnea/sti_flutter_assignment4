class RouteInfo {
  final String name;
  final String path;

  const RouteInfo({required this.name, required this.path});
}

class Routes {
  Routes._();

  static const RouteInfo homeRoute = RouteInfo(name: 'home', path: '/');
  static const RouteInfo parkingLotRoute =
      RouteInfo(name: 'parkinglot', path: '/parkinglot');
  static const RouteInfo addParkingLotRoute =
      RouteInfo(name: 'addParkinglot', path: '/addParkinglot');
  static const RouteInfo editParkingLotRoute =
      RouteInfo(name: 'editParkinglot', path: '/edit/:lotId');
  static const RouteInfo parkingRoute =
      RouteInfo(name: 'parking', path: '/parking');
  static const RouteInfo statRoute = RouteInfo(name: 'stat', path: '/stat');
  static const RouteInfo profileRoute =
      RouteInfo(name: 'profile', path: '/profile');
  static const RouteInfo loginRoute = RouteInfo(name: 'login', path: '/login');
}
