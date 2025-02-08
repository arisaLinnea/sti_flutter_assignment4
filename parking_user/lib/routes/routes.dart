class RouteInfo {
  final String name;
  final String path;

  const RouteInfo({required this.name, required this.path});
}

class Routes {
  Routes._();

  static const RouteInfo homeRoute = RouteInfo(name: 'home', path: '/');
  static const RouteInfo parkingRoute =
      RouteInfo(name: 'parking', path: '/parking');
  static const RouteInfo addParkingRoute =
      RouteInfo(name: 'addParking', path: '/addParking');
  static const RouteInfo vehicleRoute =
      RouteInfo(name: 'vehicles', path: '/vehicles');
  static const RouteInfo addVehicleRoute =
      RouteInfo(name: 'addVehicles', path: '/addVehicle');
  static const RouteInfo editVehicleRoute =
      RouteInfo(name: 'editVehicles', path: '/edit/:vehicleId');
}
