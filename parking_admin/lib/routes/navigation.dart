import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const List<NavigationRailDestination> destinations =
    <NavigationRailDestination>[
  NavigationRailDestination(
    icon: Icon(Icons.favorite_border),
    selectedIcon: Icon(Icons.favorite),
    label: Text('Home'),
  ),
  NavigationRailDestination(
    icon: FaIcon(FontAwesomeIcons.squareParking),
    selectedIcon: FaIcon(FontAwesomeIcons.squareParking, color: Colors.white),
    label: Text('Parking Lots'),
  ),
  NavigationRailDestination(
    icon: FaIcon(FontAwesomeIcons.car),
    selectedIcon: FaIcon(FontAwesomeIcons.car, color: Colors.white),
    label: Text('Parkings'),
  ),
  NavigationRailDestination(
    icon: FaIcon(FontAwesomeIcons.chartSimple),
    selectedIcon: FaIcon(FontAwesomeIcons.chartSimple, color: Colors.white),
    label: Text('Statistics'),
  ),
];
